//
//  ChatroomSettingEntity.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/21.
//

import Foundation
import BVMessagingSDK

enum ChatroomSettingEntity {
    
    struct DataSource {
        let chatroom: Chatroom
        var configuration: Configuration
        
        var info: ChatroomInfo {
            chatroom.info
        }
    }
    
    struct Configuration {
        var isAutoSend: Bool
    }
    
    enum ViewModel {
    	struct Section {
    		let header: String?
            let rows: [Row]
        }

        enum Row {
            case info(InfoTableViewCell.Configuration)
            case customCounter(InfoTableViewCell.Configuration)
            case pinMessagesInfo(InfoTableViewCell.Configuration)
            case blockUserInfo(InfoTableViewCell.Configuration)
            case mute(ButtonTableViewCell.Configuration)
            case unmute(ButtonTableViewCell.Configuration)
            case autoSend(ToggleTableViewCell.Configuration)
        }
    }
}
