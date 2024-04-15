//
//  UIView+extension.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/1/25.
//

import UIKit

extension UIView {
    
    func removeAllConstraints() {
        self.removeConstraints(self.constraints)
        for subview in self.subviews {
            subview.removeAllConstraints()
        }
    }
}
