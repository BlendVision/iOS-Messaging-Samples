//
//  Chatroom2Interfaces.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/20.
//

import Foundation
import BVMessagingSDK

// View

protocol ChatroomViewInterface: ViewInterface {
    
	func tableViewReload()
    func scrollToBottom()
    func updateInputState(_ state: ChatroomEntity.ChatroomState)
    func updateConnectionState(_ state: ConnectingState)
    func updateWordingCount(_ state: ChatroomEntity.WordingCountState, text: String)
}

// Presenter

protocol ChatroomPresenterInterface: PresenterInterface {
    
    // Chatroom Action
    
    func connect()
    func disconnect()
    func sendMessage(text: String)
    func sendLikeMessage()
    func sendDislikeMessage()
    
    // UI
    
    func showSettingPage()
    func getTitle() -> String
    func scrollViewDidScroll(contentHeight: CGFloat, tableViewHeight: CGFloat, scrollOffset: CGFloat, offsetThreshold: CGFloat)
    func textViewDidChange(_ text: String)
    
    // TableView
    
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRowAt(_ indexPath: IndexPath) -> ChatroomEntity.ViewModel.Row?
}

// Interactor

protocol ChatroomInteractorInterface: InteractorInterface {
    
    var delegate: ChatroomInteractorDelegate? { get set }
	var data: ChatroomEntity.DataSource { get }
    
    // Chatroom Action
    
    func connect() async
    func disconnect()
    func sendMessage(text: String) async
    func updateChatroomState()
    func sendLikeMessage()
    func sendDislikeMessage()
    func refreshAndReconnect()
    
    // Message Action
    
    func pinMessage(_ message: InteractionMessageText)
    func unpinMessage(_ message: InteractionMessageText)
    func deleteMessage(_ message: InteractionMessageText)
    func blockUser(_ user: ChatroomUser)
    
    // Access 
    
    func isPinnedMessage(_ message: InteractionMessageText) -> Bool
    func isBlockedUser() -> Bool
    func isMute() -> Bool
    func updateChatroomConfiguration(_ configuration: ChatroomSettingEntity.Configuration)
}

// Router

protocol ChatroomRouterInterface: RouterInterface {
    
    func backToPreviousPage()
    func showSettingPage(data: ChatroomEntity.DataSource)
    func showAlert(title: String?, description: String?)
    func showMenu(message: String, isPinned: Bool, pin: @escaping () -> Void, delete: @escaping () -> Void, block: @escaping () -> Void)
    func showRefreshTokenAlert(title: String?, description: String?, refreshHandler: @escaping (() -> Void))
}
