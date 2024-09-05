//
//  UserSettingViewController.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/1/25.
//

import UIKit
import BVMessagingSDK

class UserSettingViewController: UIViewController {

    // MARK: - Properties

    let viewModel: UserSettingViewModel

    // MARK: - UI Components

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
        tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: InfoTableViewCell.identifier)
        return tableView
    }()
    
    // MARK: - Constructors

    init(viewModel: UserSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigation()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - Data Binding

private extension UserSettingViewController {

    func setupBinding() {
        viewModel.dataDidUpdateClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.errorDidOccurClosure = { [weak self] error in
            DispatchQueue.main.async {
                let description: String
                
                if let chatroomError = error as? ChatroomError {
                    description = chatroomError.errorDescription
                } else {
                    description = error.localizedDescription
                }
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                let alertController = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
                alertController.addAction(okAction)
                
                self?.present(alertController, animated: true)
            }
        }
    }
}

// MARK: - Actions

private extension UserSettingViewController {
    
    @objc func connect() {
        dismissKeyboard()
        enableNavigationBarButton(false)
        
        viewModel.connect { [weak self] chatroom in
            self?.enableNavigationBarButton(true)
            
            guard let chatroom else { return }
            DispatchQueue.main.async {
                let viewController = ChatroomBuilder().build(chatroom: chatroom)
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func enableNavigationBarButton(_ isEnable: Bool) {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem?.isEnabled = isEnable
            self.navigationItem.leftBarButtonItem?.isEnabled = isEnable
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Setup UI

private extension UserSettingViewController {

    func setupUI() {
        view.backgroundColor = .white
    
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setupNavigation() {
        let connectButton = UIBarButtonItem(title: "Connect", style: .plain, target: self, action: #selector(connect))
        navigationItem.rightBarButtonItem = connectButton
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension UserSettingViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = viewModel.cellForRowAt(indexPath) else { return UITableViewCell() }
        
        switch data {
        case let .username(data), let .deviceID(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier) as? TextFieldTableViewCell {
                cell.configure(with: data)
                return cell
            }
        case let .roleToggle(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier) as? ToggleTableViewCell {
                cell.configure(with: data)
                return cell
            }
        case let .chatroomToken(data), let .refreshToken(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier) as? TextFieldTableViewCell {
                cell.configure(with: data)
                return cell
            }
        case let .environment(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.identifier) as? InfoTableViewCell {
                cell.configure(with: data)
                return cell
            }
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.titleForHeaderInSection(section)
    }
}
