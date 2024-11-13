//
//  InteractionTypeSelectionViewModel.swift
//  BVMessagingSDK
//
//  Created by bingkuo on 2024/10/22.
//

import Foundation
import BVMessagingSDK

extension InteractionTypeSelectionViewModel {
    struct SelectionModel {
        let title: String
        var isSelected: Bool
    }
}

class InteractionTypeSelectionViewModel {

    private(set) var items: [InteractionType]
    private(set) var selectedItems: [InteractionType]
    var reloadDataClosure: (() -> Void)?
    
    init(items: [InteractionType]) {
        self.items = InteractionType.allCases
        self.selectedItems = items
    }
    
    func numberOfRows() -> Int {
        return items.count
    }
    
    func item(at indexPath: IndexPath) -> SelectionModel {
        let type = items[indexPath.row]
        let title = type.rawValue
        let isSelected = selectedItems.contains(type)
        return SelectionModel(title: title, isSelected: isSelected)
    }
    
    func toggleSelection(at indexPath: IndexPath) {
        let type = items[indexPath.row]
        if let firstIndex = selectedItems.firstIndex(of: type) {
            selectedItems.remove(at: firstIndex)
        } else {
            selectedItems.append(type)
        }
        
        reloadDataClosure?()
    }
}
