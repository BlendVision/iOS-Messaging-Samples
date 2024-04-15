//
//  ChatroomBuilder.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/27.
//

import Foundation
import UIKit
import BVMessagingSDK

final class ChatroomBuilder {

    func build(chatroom: Chatroom) -> UIViewController {
        let router = ChatroomRouter()
        let interactor = ChatroomInteractor(chatroom: chatroom)
        let view = ChatroomViewController()
        let presenter = ChatroomPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        router.viewController = view
        interactor.delegate = presenter
        
        // refactor
        router.configurationDidUpdateClosure = {
            interactor.updateChatroomConfiguration($0)
        }
        
        return view
    }
}
