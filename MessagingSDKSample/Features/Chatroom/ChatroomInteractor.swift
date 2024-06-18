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
    private var timer: Timer?
    
    init(chatroom: Chatroom) {
        self.data = ChatroomEntity.DataSource(chatroom: chatroom)
        data.chatroom.add(listener: self)
    }
    
    deinit {
        chatroom.remove(listener: self)
    }
    
    func startPollingTimer(_ isTurnOn: Bool) {
        guard isTurnOn else {
            timer?.invalidate()
            timer = nil
            return
        }
        
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
            guard let self else { return }
            Task {
                await self.sendMessage(text: Date().ISO8601Format())
                self.delegate?.interactor(self, didUpdateData: self.data)
            }
        }
        timer?.fire()
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
        do {
            try chatroom.sendCountableCustomMessage(key: "like", text: "👍")
        } catch {
            delegate?.interactor(self, didFailed: error)
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
        startPollingTimer(configuration.isAutoSend)
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
        for message in messages {
            switch message.type {
            case .text:
                data.sentMessages.removeAll(where: { $0.id == message.id })
                delegate?.interactor(self, didUpdateData: data)
            case .mute, .unmute, .blockUser, .unblockUser:
                updateChatroomState()
                delegate?.interactor(self, didUpdateData: data)
            case .pinMessage, .unpinMessage, .deleteMessage, .viewerInfoUpdate, .viewerInfoEnabled, .viewerInfoDisabled, .custom, .customCounterUpdate, .entrance:
                delegate?.interactor(self, didUpdateData: data)
            }
        }
    }
    
    func chatroom(_ chatroom: Chatroom, didFailToReceiveMessagesWithError error: Error) {
        print("ChatroomViewModel.chatroom(_:didFailToReceiveMessagesWithError:)")
    }
    
    func chatroom(_ chatroom: Chatroom, didChangeState state: ConnectingState) {
        delegate?.interactor(self, didChangeState: state)
    }
}
