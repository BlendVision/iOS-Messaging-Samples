//
//  ChatroomInteractor.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/20.
//

import Foundation
import BVMessagingSDK

protocol ChatroomInteractorDelegate: AnyObject {
    func interactor(_ interactor: ChatroomInteractor, didUpdateData data: ChatroomEntity.DataSource)
    func interactor(_ interactor: ChatroomInteractor, didFailed error: Error)
    func interactor(_ interactor: ChatroomInteractor, didChangeState state: ConnectingState)
    func interactorDidMute(_ interactor: ChatroomInteractor)
    func interactorDidActive(_ interactor: ChatroomInteractor)
}

class ChatroomInteractor: ChatroomInteractorInterface {
    
    weak var delegate: ChatroomInteractorDelegate?
    
    private(set) var data: ChatroomEntity.DataSource
    var chatroom: Chatroom {
        data.chatroom
    }
    var user: ChatroomUser {
        chatroom.user
    }
    private var testMessageSenderTimer: Timer?
    private var syncMessageTimer: Timer?
    
    init(chatroom: Chatroom) {
        self.data = ChatroomEntity.DataSource(chatroom: chatroom)
        data.chatroom.add(listener: self)
        startSyncTimer()
    }
    
    deinit {
        chatroom.remove(listener: self)
    }
    
    func startTestMessageSenderTimer(_ isTurnOn: Bool) {
        guard isTurnOn else {
            testMessageSenderTimer?.invalidate()
            testMessageSenderTimer = nil
            return
        }
        
        guard testMessageSenderTimer == nil else { return }
        
        testMessageSenderTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
            guard let self else { return }
            Task {
                await self.sendMessage(text: Date().ISO8601Format())
                self.delegate?.interactor(self, didUpdateData: self.data)
            }
        }
        testMessageSenderTimer?.fire()
    }
    
    func startSyncTimer() {
        syncMessageTimer?.invalidate()
        syncMessageTimer = nil
        
        syncMessageTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] timer in
            guard let self else { return }
            
            Task {
                do {
                    try await self.syncMessages()
                } catch {
                    self.delegate?.interactor(self, didFailed: error)
                }
            }
        }
        syncMessageTimer?.fire()
    }
}

// MARK: - Chatroom Action

extension ChatroomInteractor {
    
    func connect() async {
        do {
            try await chatroom.connect()
        } catch {
            delegate?.interactor(self, didFailed: error)
        }
    }
    
    func disconnect() {
        chatroom.disconnect()
    }
    
    func sendMessage(text: String) async {
        do {
            let sentMessage = try chatroom.sendMessage(text: text)
            data.sentMessages.append(sentMessage)
        } catch {
            delegate?.interactor(self, didFailed: error)
        }
    }
    
    func updateChatroomState() {
        if isMute() {
            delegate?.interactorDidMute(self)
        } else {
            delegate?.interactorDidActive(self)
        }
    }
    
    func sendLikeMessage() {
        Task {
            do {
                try chatroom.sendCountableCustomMessage(key: "like", text: "👍")
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
    
    func sendDislikeMessage() {
        do {
            let json = "{\"type\":\"dislike\"}"
            try chatroom.sendCustomMessage(text: json)
        } catch {
            delegate?.interactor(self, didFailed: error)
        }
    }
    
    func refreshAndReconnect() {
        Task {
            do {
                try await chatroom.refreshToken()
                try await chatroom.reconnect()
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
    
    func fetchHistory() async throws {
        data.receivedMessages = try await chatroom.getMessage(limit: nil)
        self.delegate?.interactor(self, didUpdateData: self.data)
    }
    
    private func syncMessages() async throws {
        guard let newDate = Calendar.current.date(byAdding: .second, value: -30, to: Date()) else { return }
        
        /// There are sorted messages, you can use them directly or handle additional logic
        let remoteMessages = try await chatroom.getMessage(afterAt: newDate, limit: 100)
        let syncedMessages = syncMessages(remote: remoteMessages, local: data.receivedMessages, afterAt: newDate)
        
        data.receivedMessages = syncedMessages
        delegate?.interactor(self, didUpdateData: data)
    }
    
    /// Write the code to sync up messages between backend and local.
    private func syncMessages(remote: [InteractionMessage], local: [InteractionMessage], afterAt: Date) -> [InteractionMessage] {
        var updatedMessages = local
        
        updatedMessages.removeAll { remote.contains($0) }
        updatedMessages.append(contentsOf: remote)
        
        updatedMessages.sort { (message1, message2) in
            if let date1 = message1.receivedAt, let date2 = message2.receivedAt {
                return date1 < date2
            } else {
                return false
            }
        }
        
        return updatedMessages
    }
}
    
// MARK: - Message Action

extension ChatroomInteractor {
    
    func pinMessage(_ message: InteractionMessageText) {
        Task {
            do {
                try await chatroom.pinMessage(with: message)
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
    
    func unpinMessage(_ message: InteractionMessageText) {
        Task {
            do {
                try await chatroom.unpinMessage(id: message.id)
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
    
    func deleteMessage(_ message: InteractionMessageText) {
        Task {
            do {
                try await chatroom.deleteMessage(with: message)
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
    
    func blockUser(_ user: ChatroomUser) {
        Task {
            do {
                try await chatroom.blockUser(id: user.id, deviceID: user.deviceID, username: user.name)
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
}

// MARK: - Access
    
extension ChatroomInteractor {
    
    func isPinnedMessage(_ message: InteractionMessageText) -> Bool {
        chatroom.info.pinnedMessages.map(\.message).map(\.id).contains(message.id)
    }
    
    func isBlockedUser() -> Bool {
        chatroom.info.blockedUsers.map(\.id).contains(chatroom.user.id)
    }
    
    func isMute() -> Bool {
        chatroom.info.muted
    }
    
    func updateChatroomConfiguration(_ configuration: ChatroomSettingEntity.Configuration) {
        data.configuration = configuration
        startTestMessageSenderTimer(configuration.isAutoSend)
    }
}

// MARK: - ChatroomEventListener

extension ChatroomInteractor: ChatroomEventListener {
    func chatroom(_ chatroom: Chatroom, didFinishBatchWithIncreaseCount increment: [String : Int], totalCount: [String : Int]) {
        delegate?.interactor(self, didUpdateData: data)
        print("increment: \(increment), totalCount: \(totalCount)")
    }
    
    func chatroomDidConnect(_ chatroom: Chatroom) {
        print("ChatroomViewModel.chatroomDidConnect(_:)")
    }
    
    func chatroomDidDisconnect(_ chatroom: Chatroom) {
        print("ChatroomViewModel.chatroomDidDisconnect(_:)")
    }
    
    func chatroom(_ chatroom: Chatroom, failToConnect error: Error) {
        delegate?.interactor(self, didFailed: error)
    }
    
    func chatroom(_ chatroom: Chatroom, didDisconnectWithError error: Error) {
        delegate?.interactor(self, didFailed: error)
    }
    
    func chatroom(_ chatroom: Chatroom, didReceiveMessages messages: [InteractionMessage]) {
        var receivedMessages = [InteractionMessage]()
        var deletedMessageIDs = [String]()
        
        for message in messages {
            switch message.type {
            case .text:
                data.sentMessages.removeAll(where: { $0.id == message.id })
                receivedMessages.append(message)
            case .mute, .unmute, .blockUser, .unblockUser:
                updateChatroomState()
                receivedMessages.append(message)
            case .pinMessage, .unpinMessage, .viewerInfoUpdate, .viewerInfoEnabled, .viewerInfoDisabled, .custom, .customCounterUpdate, .entrance, .broadcastUpdate:
                receivedMessages.append(message)
            case .deleteMessage:
                if let message = message as? InteractionMessageDeleteMessage {
                    deletedMessageIDs.append(message.deleteMessage.id)
                }
            @unknown default:
                print("Unsupported message type")
            }
        }
        
        if receivedMessages.count > 0 {
            data.receivedMessages.append(contentsOf: receivedMessages)
        }
        if deletedMessageIDs.count > 0 {
            data.receivedMessages.removeAll(where: { deletedMessageIDs.contains($0.id) })
        }
        delegate?.interactor(self, didUpdateData: data)
    }
    
    func chatroom(_ chatroom: Chatroom, didFailToReceiveMessagesWithError error: Error) {
        print("ChatroomViewModel.chatroom(_:didFailToReceiveMessagesWithError:)")
    }
    
    func chatroom(_ chatroom: Chatroom, didChangeState state: ConnectingState) {
        delegate?.interactor(self, didChangeState: state)
    }
}
