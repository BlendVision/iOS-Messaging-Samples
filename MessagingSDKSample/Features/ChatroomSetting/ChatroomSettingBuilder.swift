//
//  ChatroomSettingBuilder.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/27.
//

import Foundation
import UIKit
import BVMessagingSDK

final class ChatroomSettingBuilder {
    
    func build(
        chatroom: Chatroom,
        configuration: ChatroomSettingEntity.Configuration,
        routerOutputHandler: ChatroomSettingRouterOutput? = nil
    ) -> UIViewController {
        let router = ChatroomSettingRouter()
        router.delegate = routerOutputHandler
        let interactor = ChatroomSettingInteractor(chatroom: chatroom, configuration: configuration)
        let view = ChatroomSettingViewController()
        view.hidesBottomBarWhenPushed = true
        let presenter = ChatroomSettingPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        router.viewController = view
        interactor.delegate = presenter
        
        return view
    }
}
