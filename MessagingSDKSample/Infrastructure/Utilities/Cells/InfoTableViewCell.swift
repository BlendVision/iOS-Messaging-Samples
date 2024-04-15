//
//  InfoTableViewCell.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2023/9/8.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    // MARK: - Properties

    private(set) var configuration: Configuration?

    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    lazy var valueLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Constructors

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        reset()
    }
}

// MARK: - CustomTableViewCell

extension InfoTableViewCell: CustomCell {

    typealias CellConfiguration = Configuration
    
    struct Configuration: CustomCellConfiguration {
        let title: String
        let value: String
    }

    func configure(with configuration: Configuration) {
        self.configuration = configuration
        titleLabel.text = configuration.title
        valueLabel.text = configuration.value
    }

    private func reset() {
        configuration = nil
    }
}

// MARK: - Setup UI

private extension InfoTableViewCell {

    func setupUI() {
        selectionStyle = .none

        let pending = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: pending.top),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pending.left),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pending.right),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: pending.top),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -pending.bottom),
        ])
    }
}
