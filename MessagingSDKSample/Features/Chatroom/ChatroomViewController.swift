//
//  ChatroomViewController.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/1/24.
//

import UIKit
import BVMessagingSDK



class ChatroomViewController: UIViewController {
    
    var presenter: ChatroomPresenterInterface!
    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(ChatroomLeftMessageCell.self, forCellReuseIdentifier: ChatroomLeftMessageCell.identifier)
        tableView.register(ChatroomRightMessageCell.self, forCellReuseIdentifier: ChatroomRightMessageCell.identifier)
        tableView.register(ChatroomNoticeCellTableViewCell.self, forCellReuseIdentifier: ChatroomNoticeCellTableViewCell.identifier)
        return tableView
    }()
    private lazy var inputBoxView: UIView = {
        let view = UIView()
        view.backgroundColor = .inputBoxBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 14)
        view.delegate = self
        return view
    }()
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.sendButtonTintColor, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
        button.setTitle("Send", for: .normal)
        return button
    }()
    private lazy var actionScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    private lazy var wordingWrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .actionButtonBackgroundColor
        view.layer.cornerRadius = 5
        view.addSubview(wordingCountLabel)
        NSLayoutConstraint.activate([
            wordingCountLabel.topAnchor.constraint(equalTo: view.topAnchor),
            wordingCountLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wordingCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            wordingCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        return view
    }()
    private lazy var wordingCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.sendButtonTintColor, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.backgroundColor = .actionButtonBackgroundColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
        button.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        return button
    }()
    private lazy var dislikeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.sendButtonTintColor, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.backgroundColor = .actionButtonBackgroundColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(dislikeButtonDidTap), for: .touchUpInside)
        button.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigation()
        setupHideKeyboardGesture()
        
        presenter.connect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableViewReload()
        scrollToBottom()
    }
}

extension ChatroomViewController: ChatroomViewInterface {
    
    func tableViewReload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            self.tableView.scrollToBottom()
        }
    }
    
    func updateInputState(_ state: ChatroomEntity.ChatroomState) {
        DispatchQueue.main.async {
            switch state {
            case .muted:
                self.textView.backgroundColor = .inputBoxTextViewMuteBackgroundColor
                self.textView.text = "Muted. Wait for admin to unmute."
                self.textView.isEditable = false
                self.sendButton.isEnabled = false
            case .blocked:
                self.textView.backgroundColor = .inputBoxTextViewMuteBackgroundColor
                self.textView.text = "Blocked. Wait for admin to unblock."
                self.textView.isEditable = false
                self.sendButton.isEnabled = false
            case .active:
                self.textView.backgroundColor = .white
                self.textView.text = ""
                self.textView.isEditable = true
                self.sendButton.isEnabled = true
            }
        }
    }
    
    func updateConnectionState(_ state: ConnectingState) {
        switch state {
        case .connected:
            stateLabel.text = "connected"
            stateLabel.backgroundColor = .systemGreen
        case .connecting:
            stateLabel.text = "connecting"
            stateLabel.backgroundColor = .systemYellow
        case .disconnected:
            stateLabel.text = "disconnected"
            stateLabel.backgroundColor = .systemRed
        }
    }
    
    func updateWordingCount(_ state: ChatroomEntity.WordingCountState, text: String) {
        DispatchQueue.main.async {
            self.wordingCountLabel.text = text
            switch state {
            case .valid:
                self.wordingCountLabel.textColor = .black
                self.sendButton.isEnabled = true
            case .invalid:
                self.wordingCountLabel.textColor = .systemRed
                self.sendButton.isEnabled = false
            }
        }
    }
}

// MARK: - Actions

extension ChatroomViewController {
    
    @objc func disconnect(_ sender: UITabBarItem) {
        presenter.disconnect()
    }
    
    @objc func showSettingPage(_ sender: UITabBarItem) {
        presenter.showSettingPage()
    }
    
    @objc func sendButtonDidTap(_ sender: UIButton) {
        guard !textView.text.isEmpty else { return }
        
        presenter.sendMessage(text: textView.text)
        presenter.textViewDidChange("")
        textView.text = ""
        dismissKeyboard()
    }
    
    @objc func likeButtonDidTap(_ sender: UIButton) {
        presenter.sendLikeMessage()
    }
    
    @objc func dislikeButtonDidTap(_ sender: UIButton) {
        presenter.sendDislikeMessage()
    }
}

// MARK: - UITableView Delegate

extension ChatroomViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = presenter.cellForRowAt(indexPath) else { return UITableViewCell() }
        
        switch data {
        case let .incomingMessage(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChatroomLeftMessageCell.identifier) as? ChatroomLeftMessageCell {
                cell.configure(with: data)
                return cell
            }
        case let .outgoingMessage(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChatroomRightMessageCell.identifier) as? ChatroomRightMessageCell {
                cell.configure(with: data)
                return cell
            }
        case let .notice(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChatroomNoticeCellTableViewCell.identifier) as? ChatroomNoticeCellTableViewCell {
                cell.configure(with: data)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = tableView.contentSize.height
        let tableViewHeight = tableView.bounds.size.height
        let scrollOffset = tableView.contentOffset.y
        presenter.scrollViewDidScroll(contentHeight: contentHeight, tableViewHeight: tableViewHeight, scrollOffset: scrollOffset, offsetThreshold: 200)
    }
}

// MARK: - Setup UI

private extension ChatroomViewController {
    
    func setupUI() {
        title = presenter.getTitle()
        
        view.backgroundColor = .white
        
        view.addSubview(stateLabel)
        view.addSubview(tableView)
        setupInputBoxView()
        
        NSLayoutConstraint.activate([
            stateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBoxView.topAnchor),
            
            inputBoxView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBoxView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBoxView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }
    
    func setupInputBoxView() {
        let insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        view.addSubview(inputBoxView)
        view.addSubview(actionScrollView)
        inputBoxView.addSubview(textView)
        inputBoxView.addSubview(sendButton)
        actionScrollView.addSubview(actionStackView)
        actionStackView.addArrangedSubview(wordingWrapperView)
        actionStackView.addArrangedSubview(likeButton)
        actionStackView.addArrangedSubview(dislikeButton)
        
        NSLayoutConstraint.activate([
            actionScrollView.topAnchor.constraint(equalTo: inputBoxView.topAnchor, constant: insets.top),
            actionScrollView.leadingAnchor.constraint(equalTo: inputBoxView.leadingAnchor, constant: insets.left),
            actionScrollView.trailingAnchor.constraint(equalTo: inputBoxView.trailingAnchor, constant: -insets.right),
            
            actionStackView.topAnchor.constraint(equalTo: actionScrollView.topAnchor),
            actionStackView.leadingAnchor.constraint(equalTo: actionScrollView.leadingAnchor),
            actionStackView.trailingAnchor.constraint(equalTo: actionScrollView.trailingAnchor),
            actionStackView.bottomAnchor.constraint(equalTo: actionScrollView.bottomAnchor),
            actionStackView.heightAnchor.constraint(equalTo: actionScrollView.heightAnchor),
            
            textView.topAnchor.constraint(equalTo: actionScrollView.bottomAnchor, constant: insets.top),
            textView.leadingAnchor.constraint(equalTo: inputBoxView.leadingAnchor, constant: insets.left),
            textView.bottomAnchor.constraint(equalTo: inputBoxView.bottomAnchor, constant: -insets.bottom),
            textView.heightAnchor.constraint(equalToConstant: 32),
            
            sendButton.topAnchor.constraint(equalTo: textView.topAnchor),
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: insets.right),
            sendButton.trailingAnchor.constraint(equalTo: inputBoxView.trailingAnchor, constant: -insets.right),
            sendButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            
            wordingWrapperView.heightAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            dislikeButton.heightAnchor.constraint(equalToConstant: 44),
            dislikeButton.widthAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func setupNavigation() {
        navigationItem.hidesBackButton = true
        
        let disconnectButton = UIBarButtonItem(title: "Disconnect", style: .plain, target: self, action: #selector(disconnect))
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(showSettingPage))
        navigationItem.leftBarButtonItem = disconnectButton
        navigationItem.rightBarButtonItem = menuButton
    }
}

// MARK: - Setup Keyboard

extension ChatroomViewController {
    
    func setupHideKeyboardGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        gesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate

extension ChatroomViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        presenter.textViewDidChange(textView.text)
    }
}
