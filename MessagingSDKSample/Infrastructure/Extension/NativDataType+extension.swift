//
//  NativDataType+extension.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/26.
//

import Foundation

extension Bool {
    var toString: String {
        self ? "YES" : "NO"
    }
}

extension Int {
    var toString: String {
        String(self)
    }
}
