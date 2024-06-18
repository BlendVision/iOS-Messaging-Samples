//
//  ChatroomSettingViewController.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/21.
//

import UIKit

class ChatroomSettingViewController: UIViewController {

    // MARK: - Properties

    var presenter: ChatroomSettingPresenterInterface!

    // MARK: - UI Components
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: InfoTableViewCell.identifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
        tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
        return tableView
    }()
    lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        view.isHidden = true
        return view
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigation()
    }
}

// MARK: - ViewInterface

extension ChatroomSettingViewController: ChatroomSettingViewInterface {

    func tableViewReload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func showLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            self.tableView.isHidden = isLoading
            self.indicatorView.isHidden = !isLoading
        }
    }
}

// MARK: - Actions

private extension ChatroomSettingViewController {
    
    @objc func backButtonDidTap(_ sender: UITabBarItem) {
        presenter.backButtonDidTap()
    }
    
    @objc func reloadChatroomInfo() {
        presenter.updateInfo()
    }
}

// MARK: - Setup UI

private extension ChatroomSettingViewController {

    func setupUI() {
        view.backgroundColor = .white
    
        view.addSubview(tableView)
        view.addSubview(indicatorView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func setupNavigation() {
        navigationItem.hidesBackButton = true
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonDidTap))
        navigationItem.leftBarButtonItem = backButton
        
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath"), style: .plain, target: self, action: #selector(reloadChatroomInfo))
        navigationItem.rightBarButtonItem = button
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ChatroomSettingViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = presenter.cellForRowAt(indexPath) else { return UITableViewCell() }

        switch data {
        case let .pinMessagesInfo(data), let .blockUserInfo(data), let .info(data), let .customCounter(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.identifier) as? InfoTableViewCell {
                cell.configure(with: data)
                return cell
            }
        case let .mute(data), let .unmute(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier) as? ButtonTableViewCell {
                cell.configure(with: data)
                return cell
            }
        case let .autoSend(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier) as? ToggleTableViewCell {
                cell.configure(with: data)
                return cell
            }
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        presenter.titleForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        presenter.canEditRowAt(indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteRow(indexPath)
        }
    }
}
