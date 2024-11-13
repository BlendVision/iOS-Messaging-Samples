//
//  ChatroomSettingInterfaces.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/21.
//

import Foundation
import BVMessagingSDK

// View

protocol ChatroomSettingViewInterface: ViewInterface {
    
	func tableViewReload()
    func showLoading(_ isLoading: Bool)
}

// Presenter

protocol ChatroomSettingPresenterInterface: PresenterInterface {
    
    // Chatroom
    func updateInfo()
    
    // Route
    func backButtonDidTap()
    
    // Table View
	func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRowAt(_ indexPath: IndexPath) -> ChatroomSettingEntity.ViewModel.Row?
    func titleForHeaderInSection(_ section: Int) -> String?
    func deleteRow(_ indexPath: IndexPath)
    func canEditRowAt(_ indexPath: IndexPath) -> Bool
}

// Interactor

protocol ChatroomSettingInteractorInterface: InteractorInterface {
    
    var delegate: ChatroomSettingInteractorDelegate? { get set }
	var data: ChatroomSettingEntity.DataSource { get }
    
    func unpin(messageID: String)
    func unblock(userID: String)
    func mute()
    func unmute()
    func updateViewerInfo(enabled: Bool)
    func setupIsAutoSend(_ value: Bool)
}

// Router

protocol ChatroomSettingRouterInterface: RouterInterface {
    
    func showAlert(title: String?, description: String?)
    func backToChatroomAndUpdateConfiguration(with configuration: ChatroomSettingEntity.Configuration)
    func showGetMessageDemoPage(chatroom: Chatroom)
}
