//
//  ChatroomSettingRouter.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/27.
//

import Foundation
import UIKit
import BVMessagingSDK

protocol ChatroomSettingRouterOutput: AnyObject {
    func route(_ route:  ChatroomSettingRouter, configurationDidUpdate configuration: ChatroomSettingEntity.Configuration)
}

class ChatroomSettingRouter: ChatroomSettingRouterInterface {
    
    weak var viewController: UIViewController?
    weak var delegate: ChatroomSettingRouterOutput?
    
    func showAlert(title: String?, description: String?) {
        DispatchQueue.main.async {
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
            alertController.addAction(okAction)
            
            self.viewController?.present(alertController, animated: true)
        }
    }
    
    func backToChatroomAndUpdateConfiguration(with configuration: ChatroomSettingEntity.Configuration) {
        delegate?.route(self, configurationDidUpdate: configuration)
        navigationController?.popViewController(animated: true)
    }
    
    func showGetMessageDemoPage(chatroom: Chatroom) {
        let viewModel = GetMessageDemoViewModel(chatroom: chatroom)
        let viewController = GetMessageDemoViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
