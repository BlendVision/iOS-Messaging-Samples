//
//  ChatroomSettingInteractor.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/21.
//

import Foundation
import BVMessagingSDK

protocol ChatroomSettingInteractorDelegate: AnyObject {
    func interactor(_ interactor: ChatroomSettingInteractor, didUpdateData data: ChatroomSettingEntity.DataSource)
    func interactor(_ interactor: ChatroomSettingInteractor, didFailed error: Error)
}

class ChatroomSettingInteractor: ChatroomSettingInteractorInterface {

    weak var delegate: ChatroomSettingInteractorDelegate?
	private(set) var data: ChatroomSettingEntity.DataSource
    private var chatroom: Chatroom {
        data.chatroom
    }
	
	// MARK: - Constructors
    
    init(chatroom: Chatroom, configuration: ChatroomSettingEntity.Configuration) {
        self.data = ChatroomSettingEntity.DataSource(chatroom: chatroom, configuration: configuration)
    }
}

extension ChatroomSettingInteractor {
    
    func unpin(messageID: String) {
        Task {
            do {
                try await chatroom.unpinMessage(id: messageID)
                let _ = try await chatroom.info()
                delegate?.interactor(self, didUpdateData: data)
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
    
    func unblock(userID: String) {
        Task {
            do {
                try await chatroom.unblockUser(id: userID)
                let _ = try await chatroom.info()
                delegate?.interactor(self, didUpdateData: data)
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
    
    func mute() {
        Task {
            do {
                try await chatroom.mute()
                let _ = try await chatroom.info()
                delegate?.interactor(self, didUpdateData: data)
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
    
    func unmute() {
        Task {
            do {
                try await chatroom.unmute()
                let _ = try await chatroom.info()
                delegate?.interactor(self, didUpdateData: data)
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
    
    func updateViewerInfo(enabled: Bool) {
        Task {
            do {
                try await chatroom.updateViewerInfo(enabled: enabled)
                delegate?.interactor(self, didUpdateData: data)
            } catch {
                delegate?.interactor(self, didFailed: error)
            }
        }
    }
    
    func setupIsAutoSend(_ value: Bool) {
        data.configuration.isAutoSend = value
    }
}
