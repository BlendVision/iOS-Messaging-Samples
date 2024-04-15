# BVMessagingSDK

BlendVision Messaging SDK.

## Overview

The BlendVision Chatroom iOS library written in Swift. 

### Develop Environment Requirements
- Xcode 14.2 or later
- iOS 14.0 or later
- Swift Concurrency Support

### Features
- Chatroom Management
    - Create, retrieve, and connect to chatrooms.
    - Update chatroom configurations.
- Message Handling
    - Send and receive messages within chatrooms.
    - Support pinning and unpinning messages.
    - Support message deletion.
    - Support sending custom messages.
- User Management
    - Support blocking and unblocking specific users.
    - Support muting and unmuting within chatrooms.
    - Support updating the admin's name.

## Dependencies
- [CocoaMQTT](https://github.com/emqx/CocoaMQTT)
- [MqttCocoaAsyncSocket](https://github.com/leeway1208/MqttCocoaAsyncSocket)
- [Starscream](https://github.com/daltoniam/Starscream)
- [Alamofire](https://github.com/Alamofire/Alamofire)

## Installation
### Swift Package Manager
- File > Swift Packages > Add Package Dependency
- Add URL
- Select "Up to Next Major" with "1.0.0"

### Manually 
- Download `BVMessagingSDK.xcframework`, `CocoaMQTT.xcframework`, `MqttCocoaAsyncSocket.xcframework`, `Starscream.xcframework`, and `Alamofire.xcframework` from Sources/Frameworks. 
- Drag the files into the "Frameworks and Libraries" section of your application's Xcode project.

## Get Started

- Import the BlendVision Messaging SDK.
```swift
import BVMessagingSDK
```

- Setup the `MessagingConfig`.
```swift
// An API key is a token that you provide when making API calls
let apiKey = "..."
// The uuid of the organization
let orgID = "..."
// Console log level
let logLevel: LoggerLevel = .debug

// Setup config
let config = MessagingConfig(apiKey: apiKey, organizationID: orgID, logLevel: logLevel)
MessagingManager.shared.setup(with: config)
```

- Creates a new chatroom or retrieves a specific chatroom.
```swift
let userID = "..."
let name = "..."
let deviceID = "..."
let isAdmin = true

// The user who wants to use this chatroom.
let user = ChatroomUser(id: userID, name: name, deviceID: deviceID, isAdmin: isAdmin)

// Creates a new chatroom if the user is an admin.
let chatroom = try await MessagingManager.shared.createChatroom(with: user)

// Retrieves a specific chatroom based on the permissions held by this user.
let chatroomID = "..."
let chatroom = try await MessagingManager.shared.chatroom(id: chatroomID, with: user)

// Retrieves a specific chatroom with guest permissions.
let chatroom = try await MessagingManager.shared.chatroom(id: chatroomID)
```

- Adds event listener.
```swift
// Adds a listener for receiving events.
chatroom.add(listener: self)

// Removes a listener that was previously added.
chatroom.remove(listener: self)
```

- Implement `ChatroomEventListener` protocol
```swift
extension YourModel: ChatroomEventListener {
    func chatroomDidConnect(_ chatroom: Chatroom) {
    }
    
    func chatroomDidDisconnect(_ chatroom: Chatroom) {
    }
    
    func chatroom(_ chatroom: Chatroom, failToConnect error: Error) {
    }
    
    func chatroom(_ chatroom: Chatroom, didDisconnectWithError error: Error) {
    }
    
    func chatroom(_ chatroom: Chatroom, didReceiveMessages messages: [InteractionMessage]) {
    }
    
    func chatroom(_ chatroom: Chatroom, didChangeState state: ConnectingState) {
    }
}
```

- Connects to the MQTT broker. Then you can call chatroom-related APIs.
```swift
try await chatroom.connect()

// Chatroom information
let chatroomInfo = chatroom.info

// Fetch and update the latest chatroom information
let latestChatroomInfo = chatroom.info()

// Chatroom-related APIs
try chatroom.sendMessage(text: "...")
try await chatroom.pinMessage(with: message)
...

// Close the connection
chatroom.disconnect()
```
