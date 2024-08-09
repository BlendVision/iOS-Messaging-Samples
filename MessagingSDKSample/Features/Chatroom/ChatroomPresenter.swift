//
//  ChatroomViewModel.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/1/25.
//

import Foundation
import BVMessagingSDK

class ChatroomPresenter {
     
    typealias Section = ChatroomEntity.ViewModel.Section
    typealias Row = ChatroomEntity.ViewModel.Row
    
    // MARK: - Properties
    
    private unowned let view: ChatroomViewInterface
    private let interactor: ChatroomInteractorInterface
    private let router: ChatroomRouterInterface
    private var isEndOfChatroom: Bool = false
    private var unsentMessage: String = ""
    var chatroom: Chatroom {
        interactor.data.chatroom
    }
    var isAdmin: Bool {
        chatroom.user.role == .admin
    }
    var sections: [Section] { generateSections() }
    
    // wording count
    let maxWordingCount: Int = 200
    var wordingCount: Int {
        unsentMessage.count
    }
    var wordingCountState: ChatroomEntity.WordingCountState {
        wordingCount > maxWordingCount ? .invalid : .valid
    }
    var wordingCountText: String {
        "\(wordingCount)/\(maxWordingCount)"
    }

    init(
        view: ChatroomViewInterface,
        interactor: ChatroomInteractorInterface,
        router: ChatroomRouterInterface
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.interactor.delegate = self
    }
    
    private func generateSections() -> [Section] {
        var sections = [Section]()
        var rows = [Row]()
        for interactionMessage in interactor.data.receivedMessages {
            if let message = interactionMessage as? InteractionMessageText  {
                let isOwner = (message.user.id == interactor.data.user.id)
                let isPinned = interactor.isPinnedMessage(message)
                let messageText = message.textMessage?.text ?? ""
                let username = message.user.name
                let receiveDate = message.receivedAt ?? Date()
                let pin: () -> Void = { [weak self] in
                    if isPinned {
                        self?.interactor.unpinMessage(message)
                    } else {
                        self?.interactor.pinMessage(message)
                    }
                }
                let delete: () -> Void = { [weak self] in
                    self?.interactor.deleteMessage(message)
                }
                let block: () -> Void = { [weak self] in
                    self?.interactor.blockUser(message.user)
                }

                if isOwner {
                    rows.append(
                        Row.outgoingMessage(
                            .init(
                                text: messageText,
                                username: username,
                                receiveDate: receiveDate,
                                status: isPinned ? .pinned : nil,
                                longPressHandler: { [weak self] in
                                    let isAdmin = self?.isAdmin ?? false
                                    if isAdmin {
                                        self?.router.showMenu(message: messageText, isPinned: isPinned, pin: pin, delete: delete, block: block)
                                    }
                                }
                            )
                        ))
                } else {
                    rows.append(Row.incomingMessage(
                        .init(
                            text: messageText,
                            username: username,
                            receiveDate: receiveDate,
                            status: isPinned ? .pinned : nil,
                            longPressHandler: { [weak self] in
                                let isAdmin = self?.isAdmin ?? false
                                if isAdmin {
                                    self?.router.showMenu(message: messageText, isPinned: isPinned, pin: pin, delete: delete, block: block)
                                }
                            }
                        )
                    ))
                }
            } else if let message = interactionMessage as? InteractionMessagePin {
                let actionTakerName = message.pinUnpinMessage.actionTaker.name
                let text = (message.type == .pinMessage) ? "\(actionTakerName) pinned message" : "\(actionTakerName) unpinned message"
                rows.append(Row.notice(.init(text: text)))
            } else if let message = interactionMessage as? InteractionMessageBlock {
                let isBlockUser = (message.type == .blockUser)
                let actionTakerName = message.blockUser.actionTaker.name
                let blockUserName = message.blockUser.customName
                let text = (isBlockUser) ? "\(actionTakerName) blocked user \(blockUserName)" : "\(actionTakerName) unblocked user \(blockUserName)"
                rows.append(Row.notice(.init(text: text)))
            } else if let message = interactionMessage as? InteractionMessageMute {
                let isMute = (message.type == .mute)
                let text = isMute ? "Admin muted the chatroom" : "Admin unmuted the chatroom"
                rows.append(Row.notice(.init(text: text)))
            } else if let message = interactionMessage as? InteractionMessageViewerInfo {
                switch message.type {
                case .viewerInfoDisabled:
                    rows.append(Row.notice(.init(text: "Viewer info is disabled")))
                case .viewerInfoEnabled:
                    rows.append(Row.notice(.init(text: "Viewer info is enabled")))
                case .viewerInfoUpdate:
                    rows.append(Row.notice(.init(text: "Viewer info is updated")))
                default:
                    break
                }
            } else if let message = interactionMessage as? InteractionMessageCustom {
                let customText = message.customMessage.value.replacingOccurrences(of: "\n", with: "")
                let shortText = (customText.count > 20) ? String(customText.prefix(20)) + "..." : customText
                if let increment = message.customMessage.increment {
                    rows.append(Row.notice(.init(text: "Receive custom message. key: \(increment.key), count: \(increment.value), text: \(shortText)")))
                } else {
                    rows.append(Row.notice(.init(text: "Receive custom message: \(shortText)")))
                }
            } else if let message = interactionMessage as? InteractionMessageCustomCounterUpdate {
                rows.append(Row.notice(.init(text: "Update counter: \(message.customCounter.key), count: \(message.customCounter.value)")))
            } else if let message = interactionMessage as? InteractionMessageEntrance {
                rows.append(Row.notice(.init(text: "\(message.entranceMessage.id)/\(message.entranceMessage.name) joins")))
            } else if let message = interactionMessage as? InteractionMessageBroadcastUpdate {
                rows.append(Row.notice(.init(text: "Receive broadcast message, concurrent: \(message.broadcastMessage.viewerMetrics.concurrent.count), total:  \(message.broadcastMessage.viewerMetrics.total.count)")))
            }
        }
        
        sections.append(Section(rows: rows))
        
        let sentMessageRows = interactor.data.sentMessages.map {
            Row.outgoingMessage(.init(
                text: $0.textMessage?.text ?? "",
                username: $0.user.name,
                receiveDate: Date(),
                status: interactor.isBlockedUser() ? .none : .sending,
                longPressHandler: nil
            ))
        }
        if !sentMessageRows.isEmpty {
            sections.append(Section(rows: sentMessageRows))
        }
        
        return sections
    }
}

// MARK: - Chatroom Action

extension ChatroomPresenter: ChatroomPresenterInterface {
    
    func connect() {
        Task {
            await interactor.connect()
            interactor.updateChatroomState()
            try? await interactor.fetchHistory()
            view.updateLikeCount(interactor.data.likeCount)
            view.updateWordingCount(wordingCountState, text: "\(wordingCountText)")
        }
    }
    
    func disconnect() {
        interactor.disconnect()
        router.backToPreviousPage()
    }
    
    func sendMessage(text: String) {
        Task {
            await interactor.sendMessage(text: text)
            view.tableViewReload()
            view.scrollToBottom()
        }
    }
    
    func sendLikeMessage() {
        interactor.sendLikeMessage()
    }
    
    func sendDislikeMessage() {
        interactor.sendDislikeMessage()
    }
}

// MARK: - UI Related

extension ChatroomPresenter {
    
    func getTitle() -> String {
        interactor.data.user.name
    }
    
    func showSettingPage() {
        router.showSettingPage(data: interactor.data)
    }
    
    func scrollViewDidScroll(contentHeight: CGFloat, tableViewHeight: CGFloat, scrollOffset: CGFloat, offsetThreshold: CGFloat) {
        isEndOfChatroom = (contentHeight - scrollOffset <= tableViewHeight + offsetThreshold)
    }
    
    func textViewDidChange(_ text: String) {
        unsentMessage = text
        view.updateWordingCount(wordingCountState, text: "\(wordingCountText)")
    }
}

// MARK: - Table View

extension ChatroomPresenter {
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        sections[safe: section]?.rows.count ?? 0
    }
    
    func cellForRowAt(_ indexPath: IndexPath) -> Row? {
        sections[safe: indexPath.section]?.rows[safe: indexPath.row]
    }
    
    func numberOfSections() -> Int {
        sections.count
    }
}

// MARK: - ChatroomInteractorDelegate

extension ChatroomPresenter: ChatroomInteractorDelegate {
    
    func interactor(_ interactor: ChatroomInteractor, didUpdateData data: ChatroomEntity.DataSource) {
        view.tableViewReload()
        view.updateLikeCount(data.likeCount)
        
        if isEndOfChatroom {
            view.scrollToBottom()
        }
    }
    
    func interactor(_ interactor: ChatroomInteractor, didFailed error: Error) {
        guard let chatroomError = error as? ChatroomError else {
            router.showAlert(title: "Error", description: error.localizedDescription)
            return
        }
        
        switch chatroomError {
        case .tokenExpired:
            router.showRefreshTokenAlert(title: "Error", description: chatroomError.errorDescription) { [weak self] in
                self?.interactor.refreshAndReconnect()
            }
        default:
            router.showAlert(title: "Error", description: chatroomError.errorDescription)
        }
    }
    
    func interactorDidMute(_ interactor: ChatroomInteractor) {
        view.updateInputState(.muted)
    }
    
    func interactorDidActive(_ interactor: ChatroomInteractor) {
        view.updateInputState(.active)
    }
    
    func interactor(_ interactor: ChatroomInteractor, didChangeState state: ConnectingState) {
        view.updateConnectionState(state)
    }
}

extension ChatroomError {
    var errorDescription: String {
        switch self {
        case .unauthorized:
            return "You don't have permission."
        case .noInternet:
            return "No Internet"
        case let .serverError(code, reason):
            return "Server error: code = \(code), reason = \(reason)"
        case let .internalError(reason):
            return "Internal error: reason = \(reason)"
        case .undefinedError:
            return "Something went wrong."
        case .tokenExpired:
            return "Token is expired."
        case let .customCounterKeyNotFound(key):
            return "Custom Counter Key '\(key)' Not Found"
        case .refreshTokenNotFound:
            return "Refresh Token Not Found"
        }
    }
}
