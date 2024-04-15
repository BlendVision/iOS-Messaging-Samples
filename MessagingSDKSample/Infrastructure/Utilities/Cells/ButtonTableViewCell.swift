//
//  ButtonTableViewCell.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2023/9/8.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    // MARK: - Properties

    private(set) var configuration: Configuration?

    lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        return button
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

extension ButtonTableViewCell: CustomCell {

    typealias CellConfiguration = Configuration
    
    enum Category {
        case normal
        case dangerous
    }

    struct Configuration: CustomCellConfiguration {
        let title: String
        let category: Category
        let clickActionHandler: (() -> Void)?

        init(
            title: String,
            category: Category = .normal,
            clickActionHandler: (() -> Void)? = nil
        ) {
            self.title = title
            self.category = category
            self.clickActionHandler = clickActionHandler
        }
    }

    func configure(with configuration: Configuration) {
        self.configuration = configuration
        button.setTitle(configuration.title, for: .normal)

        switch configuration.category {
        case .normal:
            button.setTitleColor(.systemBlue, for: .normal)
        case .dangerous:
            button.setTitleColor(.red, for: .normal)
        }
    }

    private func reset() {
        configuration = nil
        button.setTitle( nil, for: .normal)
        button.setTitleColor(.black, for: .normal)
    }
}

// MARK: - Actions

private extension ButtonTableViewCell {

    @objc func buttonDidTap(_ sender: UIButton) {
        configuration?.clickActionHandler?()
    }
}

// MARK: - Setup UI

private extension ButtonTableViewCell {

    func setupUI() {
        contentView.addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
