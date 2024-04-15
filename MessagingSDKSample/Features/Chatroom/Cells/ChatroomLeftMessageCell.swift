//
//  ChatroomLeftMessageCell.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/3.
//

import UIKit

class ChatroomLeftMessageCell: UITableViewCell {
    
    private let padding: CGFloat = 8
    private let nameLabelPadding: CGFloat = 4
    private let messageEdgePadding: CGFloat = 30
    private var configuration: CellConfiguration?
    private var longPressHandler: (() -> Void)?
    
    // MARK: - UI properties
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var messageView: ChatroomMessageView = {
        let view = ChatroomMessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 8
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        view.addGestureRecognizer(gesture)
        return view
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    lazy var statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        longPressHandler?()
    }
}

extension ChatroomLeftMessageCell: CustomCell {
    
    typealias Configuration = CellConfiguration
    
    enum Status {
        case sending
        case pinned
    }
    
    struct CellConfiguration: CustomCellConfiguration {
        let text: String
        let username: String
        let receiveDate: Date
        let status: Status?
        let longPressHandler: (() -> Void)?
    }
    
    func configure(with configuration: Configuration) {
        self.configuration = configuration
        messageView.configure(text: configuration.text)
        nameLabel.text = configuration.username
        
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        timeLabel.text = format.string(from: configuration.receiveDate)
        
        switch configuration.status {
        case .pinned:
            statusImageView.image = UIImage(systemName: "pin.fill")?.withRenderingMode(.alwaysTemplate)
        case .sending:
            statusImageView.image = UIImage(systemName: "arrow.up.left")?.withRenderingMode(.alwaysTemplate)
        case .none:
            statusImageView.image = nil
        }
        
        longPressHandler = configuration.longPressHandler
    }
}

// MARK: - Setup UI

private extension ChatroomLeftMessageCell {
    
    func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageView)
        containerView.addSubview(timeLabel)
        containerView.addSubview(statusImageView)
        
        messageView.backgroundColor = .leftMessageColor
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            messageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: nameLabelPadding),
            messageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            messageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            timeLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: padding),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -messageEdgePadding),
            
            statusImageView.topAnchor.constraint(equalTo: messageView.topAnchor),
            statusImageView.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            statusImageView.widthAnchor.constraint(equalToConstant: 14),
            statusImageView.heightAnchor.constraint(equalToConstant: 14),
        ])
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        self.addGestureRecognizer(gesture)
    }
}
