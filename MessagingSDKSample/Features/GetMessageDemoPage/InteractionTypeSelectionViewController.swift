//
//  InteractionTypeSelectionViewController.swift
//  MessagingSDKSample
//
//  Created by bingkuo on 2024/10/22.
//

import UIKit
import BVMessagingSDK

class InteractionTypeSelectionViewController: UIViewController {

    private let viewModel: InteractionTypeSelectionViewModel
    private var didSelectItems: (([InteractionType]) -> Void)?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    init(items: [InteractionType], didSelectItems: @escaping ([InteractionType]) -> Void) {
        self.viewModel = InteractionTypeSelectionViewModel(items: items)
        self.didSelectItems = didSelectItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
    }

    private func setupUI() {
        title = "Select Items"
        view.backgroundColor = .white

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(confirmSelection))
    }

    private func setupBindings() {
        viewModel.reloadDataClosure = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    @objc private func confirmSelection() {
        didSelectItems?(viewModel.selectedItems)
        navigationController?.popViewController(animated: true)
    }
}

extension InteractionTypeSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = viewModel.item(at: indexPath)
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isSelected ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleSelection(at: indexPath)
    }
}
