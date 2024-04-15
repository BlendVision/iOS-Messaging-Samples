//
//  CustomTableViewCell.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/1/25.
//

import UIKit

protocol CustomCellConfiguration { }

protocol CustomCell: UITableViewCell {
    
    associatedtype Configuration: CustomCellConfiguration
    
    func configure(with configuration: Configuration)
}
