//
//  ChatroomSettingPresenter.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/21.
//

import Foundation
import BVMessagingSDK

class ChatroomSettingPresenter: ChatroomSettingPresenterInterface {
   
    typealias Section = ChatroomSettingEntity.ViewModel.Section
    typealias Row = ChatroomSettingEntity.ViewModel.Row

    // MARK: - Properties

    private unowned let view: ChatroomSettingViewInterface
    private let interactor: ChatroomSettingInteractorInterface
    private let router: ChatroomSettingRouterInterface

    var sections: [Section] { generateSections() }
    var chatroom: Chatroom {
        interactor.data.chatroom
    }
    var chatroomInfo: ChatroomInfo {
        interactor.data.info
    }
    var isAdmin: Bool {
        chatroom.user.role == .admin
    }
    
    // MARK: - Constructors

    init(
        view: ChatroomSettingViewInterface,
        interactor: ChatroomSettingInteractorInterface,
        router: ChatroomSettingRouterInterface
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.interactor.delegate = self
    }
}

// MARK: - Extension

extension ChatroomSettingPresenter {

    func generateSections() -> [Section] {
        var sections = [Section]()
        
        sections.append(
            Section(header: "User", rows: [
                Row.info(.init(title: "Name", value: chatroom.user.name)),
                Row.info(.init(title: "User ID", value: chatroom.user.id)),
                Row.info(.init(title: "Device ID", value: chatroom.user.deviceID)),
                Row.info(.init(title: "Role", value: chatroom.user.role.rawValue)),
            ])
        )
        
        sections.append(
            Section(header: "Info", rows: [
                Row.info(.init(title: "Chatroom ID", value: chatroomInfo.identifier)),
                Row.info(.init(title: "Status", value: chatroomInfo.status)),
                Row.info(.init(title: "viewer Info Enable", value: chatroomInfo.viewerInfo.enabled.toString)),
                Row.info(.init(title: "viewer Count", value: chatroomInfo.viewerInfo.count.toString)),
                Row.info(.init(title: "viewer Version", value: chatroomInfo.viewerInfo.versionNumber)),
                Row.info(.init(title: "Create Date", value: chatroomInfo.createdAt)),
                Row.info(.init(title: "Update Date", value: chatroomInfo.updatedAt))
            ])
        )
        
        let customCounterMessageRows = chatroomInfo.customCounters
            .map {
                Row.customCounter(.init(
                    title: $0.key,
                    value: "value: \($0.value), version: \($0.versionNumber), updatedAt: \($0.updatedAt ?? "null")"
                ))
            }
        sections.append(Section(header: "Custom Counter", rows: customCounterMessageRows))
        
        let pinUnpinMessageRows = chatroomInfo.pinnedMessages
            .map {
                Row.pinMessagesInfo(.init(
                    title: $0.message.text,
                    value: "tacker: \($0.actionTaker.name)/\($0.actionTaker.id)"
                ))
            }
        sections.append(Section(header: "Pin Message", rows: pinUnpinMessageRows))
        
        let blockedUserRows = chatroomInfo.blockedUsers
            .map {
                Row.blockUserInfo(.init(
                    title: "\($0.customName)/\($0.id)",
                    value: "tacker: \($0.actionTaker.name)/\($0.actionTaker.id)"
                ))
            }
        sections.append(Section(header: "Block User", rows: blockedUserRows))
        
        if isAdmin {
            sections.append(contentsOf: [
                Section(header: "Mute/Unmute", rows: [
                    Row.mute(.init(
                        title: (chatroomInfo.muted) ? "Unmute" : "Mute",
                        category: (chatroomInfo.muted) ? .normal : .dangerous,
                        clickActionHandler: { [weak self] in
                            if self?.chatroomInfo.muted ?? false {
                                self?.interactor.unmute()
                            } else {
                                self?.interactor.mute()
                            }
                        }
                    ))
                ]),
                Section(header: "Viewer Info Enable/Disable", rows: [
                    Row.mute(.init(
                        title: (chatroomInfo.viewerInfo.enabled) ? "Disable" : "Enable",
                        category: (chatroomInfo.viewerInfo.enabled) ? .dangerous : .normal,
                        clickActionHandler: { [weak self] in
                            if let enable = self?.chatroomInfo.viewerInfo.enabled {
                                self?.interactor.updateViewerInfo(enabled: !enable)
                            }
                        }
                    ))
                ]),
            ])
        }
        
        sections.append(
            Section(header: "Testing", rows: [
                Row.autoSend(.init(
                    title: "Auto send message",
                    value: interactor.data.configuration.isAutoSend,
                    dataUpdatedHandler: { [weak self] value in
                        self?.interactor.setupIsAutoSend(value)
                    }
                ))
            ])
        )
        
        return sections
    }
}

// MARK: - Chatroom

extension ChatroomSettingPresenter {
    
    func updateInfo() {
        Task {
            view.showLoading(true)
            let _ = try await chatroom.info()
            view.showLoading(false)
            view.tableViewReload()
        }
    }
}

// MARK: - Router

extension ChatroomSettingPresenter {
    
    func backButtonDidTap() {
        router.backToChatroomAndUpdateConfiguration(with: interactor.data.configuration)
    }
}


// MARK: - UITableView

extension ChatroomSettingPresenter {
    
    func numberOfSections() -> Int {
        sections.count
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        sections[safe: section]?.rows.count ?? 0
    }

    func cellForRowAt(_ indexPath: IndexPath) -> Row? {
        sections[safe: indexPath.section]?.rows[safe: indexPath.row]
    }

    func titleForHeaderInSection(_ section: Int) -> String? {
        sections[safe: section]?.header
    }
    
    func deleteRow(_ indexPath: IndexPath) {
        guard let row = cellForRowAt(indexPath) else { return }

        switch row {
        case .pinMessagesInfo:
            let pinUnpinMessage = chatroomInfo.pinnedMessages[indexPath.row]
            interactor.unpin(messageID: pinUnpinMessage.message.id)
        case .blockUserInfo:
            let blockUser = chatroomInfo.blockedUsers[indexPath.row]
            interactor.unblock(userID: blockUser.id)
        case .mute, .unmute, .info, .autoSend, .customCounter:
            break
        }
    }
    
    func canEditRowAt(_ indexPath: IndexPath) -> Bool {
        guard
            chatroom.user.isAdmin,
            let row = cellForRowAt(indexPath)
        else { return false }

        switch row {
        case .pinMessagesInfo, .blockUserInfo:
            return true
        case .mute, .unmute, .info, .autoSend, .customCounter:
            return false
        }
    }
}

extension ChatroomSettingPresenter: ChatroomSettingInteractorDelegate {
    
    func interactor(_ interactor: ChatroomSettingInteractor, didUpdateData data: ChatroomSettingEntity.DataSource) {
        view.tableViewReload()
    }
    
    func interactor(_ interactor: ChatroomSettingInteractor, didFailed error: Error) {
        let description: String
        
        if let chatroomError = error as? ChatroomError {
            description = chatroomError.errorDescription
        } else {
            description = error.localizedDescription
        }
        
        router.showAlert(title: "Error", description: description)
    }
}
