//
//  ChatroomEntity.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/20.
//

import Foundation
import BVMessagingSDK

struct ChatroomEntity {
    
    struct ViewModel {
        struct Section {
            var rows: [Row]
        }
        
        enum Row {
            case incomingMessage(ChatroomLeftMessageCell.Configuration)
            case outgoingMessage(ChatroomRightMessageCell.Configuration)
            case notice(ChatroomNoticeCellTableViewCell.Configuration)
        }
    }
    
    enum WordingCountState {
        case valid
        case invalid
    }
    
    enum ChatroomState {
        case active
        case muted
        case blocked
    }
    
    struct DataSource {
        let chatroom: Chatroom
        var user: ChatroomUser {
            chatroom.user
        }
        var sentMessages = [InteractionMessageText]()
        var configuration = ChatroomSettingEntity.Configuration(isAutoSend: false)
    }
}
