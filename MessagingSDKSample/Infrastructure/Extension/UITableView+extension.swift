//
//  UITableView+extension.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/16.
//

import UIKit

extension UITableView {
    
    func scrollToBottom() {
        let numberOfRows = numberOfRows(inSection: numberOfSections - 1)
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
            scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
