//
//  AppDelegate.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/4/15.
//

import UIKit
import BVMessagingSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupNavigationBarAppearance()
        setupTabBarAppearance()
        
        let maxReconnectCountInCache = DataSource.maxReconnectCount
        setupMessaging(batchProcessingInterval: 2, batchSendInterval: 5, maxReconnectCount: maxReconnectCountInCache)
        
        return true
    }
    
    func setupMessaging(batchProcessingInterval: TimeInterval, batchSendInterval: TimeInterval, maxReconnectCount: Int) {
        let config = MessagingConfig(
            logLevel: .debug,
            batchProcessingInterval: batchProcessingInterval,
            batchSendInterval: batchSendInterval,
            maxReconnectCount: maxReconnectCount
        )
        MessagingManager.shared.setup(with: config)
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .navigationBarBackgroundColor
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .tabBarBackgroundColor
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

