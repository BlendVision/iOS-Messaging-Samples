//
//  UserSettingViewModel.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/1/25.
//

import Foundation
import BVMessagingSDK
import UIKit

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
        case autoSyncData(ToggleTableViewCell.CellConfiguration)
        case maxReconnectCount(TextFieldTableViewCell.CellConfiguration)
        case environment(InfoTableViewCell.CellConfiguration)
    }
    
    struct Data {
        var chatroomToken: String
        var refreshToken: String?
        let manager: MessagingManager
        let userIndex: Int
        var maxReconnectCount: Int {
            get { DataSource.maxReconnectCount }
            set { DataSource.maxReconnectCount = newValue }
        }
        var autoSyncData: Bool {
            get { DataSource.autoSyncData }
            set { DataSource.autoSyncData = newValue }
        }
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
            ]),
            .init(header: nil, rows: [
                .autoSyncData(.init(title: "Auto Sync Data", value: data.autoSyncData, dataUpdatedHandler: updateAutoSyncData)),
                .maxReconnectCount(.init(title: "Max Reconnect Count", value: String(data.maxReconnectCount), valueUpdatedHandler: updateMaxReconnectCount))
            ]),
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
    
    func updateMaxReconnectCount(_ value: String?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let maxReconnectCount = Int(value ?? "0") ?? 0
        data.maxReconnectCount = maxReconnectCount
        appDelegate.setupMessaging(batchProcessingInterval: 2, batchSendInterval: 5, maxReconnectCount: maxReconnectCount)
    }
    
    func updateAutoSyncData(_ value: Bool) {
        data.autoSyncData = value
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
