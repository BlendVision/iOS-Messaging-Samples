//
//  ChatroomNoticeCellTableViewCell.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/2/6.
//

import UIKit

class ChatroomNoticeCellTableViewCell: UITableViewCell {
    
    private(set) var configuration: Configuration?

    // MARK: - UI properties
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .noticeBackgroundColor
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        return label
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - CustomTableViewCell

extension ChatroomNoticeCellTableViewCell: CustomCell {
    
    typealias Configuration = CellConfiguration

    struct CellConfiguration: CustomCellConfiguration {
        let text: String
        let receiveDate: Date
    }

    func configure(with configuration: Configuration) {
        self.configuration = configuration
        titleLabel.text = configuration.text
        let format = DateFormatter()
        format.dateFormat = "HH:mm:ss.SSS"
        timeLabel.text = format.string(from: configuration.receiveDate)
    }
}

// MARK: - Setup UI

private extension ChatroomNoticeCellTableViewCell {

    func setupUI() {
        selectionStyle = .none
        
        let pending: CGFloat = 6
        
        contentView.addSubview(containerView)
        containerView.addSubview(timeLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: pending),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -pending),
            
            timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: pending),
            timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: pending * 2),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -pending * 2),
            
            titleLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: pending * 2),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -pending * 2),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -pending),
        ])
    }
}
