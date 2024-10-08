//
//  UserSettingViewModel.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/1/25.
//

import Foundation
import BVMessagingSDK

extension UserSettingViewModel {

    /// Display on the TableView
    struct Section {
        let header: String?
        let rows: [Row]
    }

    enum Row {
        case username(TextFieldTableViewCell.CellConfiguration)
        case deviceID(TextFieldTableViewCell.CellConfiguration)
        case roleToggle(ToggleTableViewCell.CellConfiguration)
        case chatroomToken(TextFieldTableViewCell.CellConfiguration)
        case refreshToken(TextFieldTableViewCell.CellConfiguration)
        case environment(InfoTableViewCell.CellConfiguration)
    }
    
    struct Data {
        var chatroomToken: String
        var refreshToken: String?
        let manager: MessagingManager
        let userIndex: Int
        
        var user: ChatroomUser {
            DataSource.getUser(index: userIndex)
        }
    }
}

class UserSettingViewModel {

    // MARK: - Properties
    
    var dataDidUpdateClosure: (() -> Void)?
    var errorDidOccurClosure: ((Error) -> Void)?
    
    private let api: APIService
    private(set) var data: Data
    var sections: [Section] { generateSections() }
    
    // MARK: - Constructors

    init(api: APIService = .shared, manager: MessagingManager = MessagingManager.shared, userIndex: Int) {
        self.api = api
        self.data = Data(chatroomToken: "", refreshToken: nil, manager: manager, userIndex: userIndex)
    }
    
    func connect(_ completionHandler: @escaping (Chatroom?) -> Void) {
        Task {
            do {
                // Connect to the chatroom
                let chatroom = try await MessagingManager.shared.chatroom(with: data.chatroomToken, refreshToken: data.refreshToken)
                
                // Try to rename for the user if the user is an admin
                try? await chatroom.updateUser(name: data.user.name)
                
                completionHandler(chatroom)
            } catch {
                completionHandler(nil)
                errorDidOccurClosure?(error)
            }
        }
    }
}

// MARK: - Private

private extension UserSettingViewModel {
    func generateSections() -> [Section] {
        return [
            .init(header: nil, rows: [
                .username(.init(title: "Username", value: data.user.name, valueUpdatedHandler: updateUsername)),
                .deviceID(.init(title: "Device ID", value: data.user.deviceID, valueUpdatedHandler: updateDeviceID)),
                .roleToggle(.init(title: "Is Admin", value: data.user.isAdmin, dataUpdatedHandler: updateRole))
            ]),
            .init(header: nil, rows: [
                .chatroomToken(.init(title: "Chatroom Token", value: data.chatroomToken, valueUpdatedHandler: updateChatroomToken)),
                .refreshToken(.init(title: "Refresh Token", value: data.refreshToken, valueUpdatedHandler: updateRefreshToken))
            ])
        ]
    }
    
    func updateUsername(_ value: String?) {
        DataSource.updateUser(index: data.userIndex, name: value)
    }
    
    func updateDeviceID(_ value: String?) {
        DataSource.updateUser(index: data.userIndex, id: value, deviceID: value)
    }
    
    func updateRole(_ value: Bool) {
        DataSource.updateUser(index: data.userIndex, isAdmin: value)
    }
    
    func updateChatroomToken(_ value: String?) {
        data.chatroomToken = value ?? ""
    }
    
    func updateRefreshToken(_ value: String?) {
        data.refreshToken = value ?? ""
    }
}

// MARK: - TableView

extension UserSettingViewModel {

    func numberOfSections() -> Int {
        sections.count
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        sections[section].rows.count
    }

    func cellForRowAt(_ indexPath: IndexPath) -> Row? {
        sections[indexPath.section].rows[indexPath.row]
    }

    func titleForHeaderInSection(_ section: Int) -> String? {
        sections[section].header
    }
}
