//
//  DataSource.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/1/26.
//

import Foundation
import BVMessagingSDK

class DataSource {
    
    private static var users: [ChatroomUser] {
        get {
            guard
                let data = UserDefaults.standard.object(forKey: UserDefaults.Keys.users) as? Data,
                let users = try? JSONDecoder().decode([ChatroomUser].self, from: data)
            else { return [] }
            return users
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(encoded, forKey: UserDefaults.Keys.users)
        }
    }
    
    static var maxReconnectCount: Int {
        get {
            guard
                let data = UserDefaults.standard.object(forKey: UserDefaults.Keys.maxReconnectCount) as? Data,
                let count = try? JSONDecoder().decode(Int.self, from: data)
            else { return 0 }
            return count
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(encoded, forKey: UserDefaults.Keys.maxReconnectCount)
        }
    }
    
    static var autoSyncData: Bool {
        get {
            guard
                let data = UserDefaults.standard.object(forKey: UserDefaults.Keys.autoSyncData) as? Data,
                let count = try? JSONDecoder().decode(Bool.self, from: data)
            else { return true }
            return count
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(encoded, forKey: UserDefaults.Keys.autoSyncData)
        }
    }
    
    static func getUser(index: Int) -> ChatroomUser {
        guard let user = users[safe: index] else {
            users.append(ChatroomUser.defaultUser)
            return getUser(index: index)
        }
        
        return user
    }
    
    static func updateUser(index: Int, id: String? = nil, name: String? = nil, deviceID: String? = nil, isAdmin: Bool? = nil) {
        guard index < users.count else { return }
        let user = users[index]
        let newUser = ChatroomUser(
            id: (id == nil) ? user.id : id!,
            name: (name == nil) ? user.name : name!,
            deviceID: (deviceID == nil) ? user.deviceID : deviceID!,
            isAdmin: (isAdmin == nil) ? user.isAdmin : isAdmin!
        )
        users[index] = newUser
    }
}

private extension ChatroomUser {
    
    static var defaultUser: ChatroomUser {
        let id = UUID().uuidString
        let user = ChatroomUser(id: id, name: "admin", deviceID: id, isAdmin: true)
        return user
    }
}
