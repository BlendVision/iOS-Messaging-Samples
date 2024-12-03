//
//  Chatroom2Router.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/20.
//

import Foundation
import UIKit
import BVMessagingSDK

class ChatroomRouter: ChatroomRouterInterface {

    // MARK: - Properties
    
    weak var viewController: UIViewController?
    
    var configurationDidUpdateClosure: ((ChatroomSettingEntity.Configuration) -> Void)?

    // MARK: - Module setup
    
    func backToPreviousPage() {
        navigationController?.popViewController(animated: true)
    }
    
    func showSettingPage(data: ChatroomEntity.DataSource) {
        DispatchQueue.main.async {
            let viewController = ChatroomSettingBuilder()
                .build(chatroom: data.chatroom,
                       configuration: data.configuration,
                       routerOutputHandler: self)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func showAlert(title: String?, description: String?) {
        DispatchQueue.main.async {
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
            alertController.addAction(okAction)
            
            self.viewController?.present(alertController, animated: true)
        }
    }
    
    func showRefreshTokenAlert(title: String?, description: String?, refreshHandler: @escaping (() -> Void)) {
        DispatchQueue.main.async {
            let refreshAction = UIAlertAction(title: "Refresh", style: .default) { _ in
                refreshHandler()
            }
            let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
            alertController.addAction(refreshAction)
            
            self.viewController?.present(alertController, animated: true)
        }
    }
    
    func showMenu(
        message: String,
        isPinned: Bool,
        pin: @escaping () -> Void,
        delete: @escaping () -> Void,
        block: @escaping () -> Void
    ) {
        DispatchQueue.main.async {
            let pinAction = UIAlertAction(title: isPinned ? "Unpin" : "Pin", style: .default) { _ in pin() }
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in delete() }
            let blockAction = UIAlertAction(title: "Block", style: .destructive) { _ in block() }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            let alertController = UIAlertController(title: "Actions", message: message, preferredStyle: .actionSheet)
            alertController.addAction(pinAction)
            alertController.addAction(deleteAction)
            alertController.addAction(blockAction)
            alertController.addAction(cancelAction)
            
            self.viewController?.present(alertController, animated: true)
        }
    }
    
    func showReconnectAlert(reconnectHandler: @escaping (() -> Void)) {
        Task { @MainActor in
            let alertController = UIAlertController(title: "Reminder", message: "Your chatroom was disconnected. Do you want to reconnect now?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Give Up", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Reconnect", style: .default, handler: { _ in
                reconnectHandler()
            }))
            
            self.viewController?.present(alertController, animated: true)
        }
    }
}

extension ChatroomRouter: ChatroomSettingRouterOutput {
    func route(_ route: ChatroomSettingRouter, configurationDidUpdate configuration: ChatroomSettingEntity.Configuration) {
        configurationDidUpdateClosure?(configuration)
    }
}
