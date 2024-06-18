//
//  APIService.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/5/28.
//

import Foundation
import BVMessagingSDK

struct ChatroomTokenResponse: Codable {
    let token: String
    let expiresIn: Int
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case token
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}

enum APIMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class APIService {
    static let shared = APIService()
    
    let domain = URL(string: "https://api.one.blendvision.com/bv/chatroom/v1/chatrooms")!
    let orgID = ""
    let apiKey = ""
    
    private init() { 
        guard !orgID.isEmpty, !apiKey.isEmpty else {
            fatalError("Please provide your organization ID and API key. You can sign up for them at app.one.blendvision.com.")
        }
    }
    
    private func sendRequest<T: Codable>(url: URL, method: APIMethod, body: [String: Any]?) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue(orgID, forHTTPHeaderField: "x-bv-org-id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(T.self, from: data)
        return result
    }
    
    func createChatroomToken(with chatroomID: String, user: ChatroomUser?) async throws -> ChatroomTokenResponse {
        let url = domain.appendingPathComponent("\(chatroomID)/tokens")
    
        var params = [String: Any]()
        if let user {
            params["role"] = (user.isAdmin) ? "ROLE_ADMIN" : "ROLE_VIWER"
            params["device_id"] = user.deviceID
            params["subject"] = user.id
            params["name"] = user.name
        }
        #if DEBUG
        params["expired_at"] = ISO8601DateFormatter().string(from: Calendar.current.date(byAdding: .second, value: 60*30, to: Date())!)
        #endif
        
        let result: ChatroomTokenResponse = try await sendRequest(
            url: url,
            method: .post,
            body: params
        )
        
        return result
    }
}
