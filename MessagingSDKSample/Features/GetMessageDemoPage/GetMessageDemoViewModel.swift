//
//  GetMessageDemoViewModel.swift
//  BVMessagingSDK
//
//  Created by bingkuo on 2024/10/22.
//

import Foundation
import BVMessagingSDK

class GetMessageDemoViewModel {
    
    private let chatroom: Chatroom
    private(set) var data: Data
    var sections: [Section] { generateSections() }
    
    var reloadDataClosure: (() -> Void)?
    var showInteractionTypeSelectionPageClosure: (([InteractionType]) -> Void)?
    
    init(chatroom: Chatroom) {
        self.chatroom = chatroom
        self.data = Data()
    }
    
    func updateSelectedTypes(_ selectedTypes: [InteractionType]) {
        data.selectedTypes = selectedTypes
        reloadDataClosure?()
    }
}

// MARK: - Private

extension GetMessageDemoViewModel {
    
    func generateSections() -> [Section] {
        [
            .init(header: "Parameters", rows: [
                .typeSelectionText(.init(title: "Selected Types", value: data.selectedTypesText) { [weak self] in
                    let selectedTypes = self?.data.selectedTypes ?? []
                    self?.showInteractionTypeSelectionPageClosure?(selectedTypes)
                }),
                .submitButton(.init(title: "GET") { [weak self] in
                    self?.getMessages()
                })
            ]),
            .init(header: "Result", rows: [
                .result(.init(title: "Response", value: data.response ?? ""))
            ])
        ]
    }
    
    func getMessages() {
        Task {
            do {
                let messages = try await chatroom.getMessage( limit: 100, types: data.selectedTypes)
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let messagesData = try encoder.encode(messages)
                if let string = String(data: messagesData, encoding: .utf8) {
                    data.response = string
                    reloadDataClosure?()
                }
            } catch {
                data.response = error.localizedDescription
                reloadDataClosure?()
            }
        }
    }
}

// MARK: - Data Struction

extension GetMessageDemoViewModel {
    /// Display on the TableView
    struct Section {
        let header: String?
        let rows: [Row]
    }

    enum Row {
        case typeSelectionText(InfoTableViewCell.CellConfiguration)
        case submitButton(ButtonTableViewCell.Configuration)
        case result(InfoTableViewCell.CellConfiguration)
    }
    
    struct Data {
        var selectedTypes: [InteractionType] = []
        var selectedTypesText: String {
            guard !selectedTypes.isEmpty else { return "None" }
            return selectedTypes.map(\.rawValue).joined(separator: ", ")
        }
        var response: String?
    }
}

// MARK: - TableView

extension GetMessageDemoViewModel {

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
