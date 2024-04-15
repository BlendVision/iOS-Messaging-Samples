//
//  ToggleTableViewCell.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2023/9/3.
//

import UIKit

class ToggleTableViewCell: UITableViewCell {

    // MARK: - Properties

    private(set) var configuration: Configuration?

    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
        return toggle
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

extension ToggleTableViewCell: CustomCell {
    
    typealias Configuration = CellConfiguration

    struct CellConfiguration: CustomCellConfiguration {
        let title: String
        let value: Bool
        let dataUpdatedHandler: (Bool) -> Void

        init(
            title: String,
            value: Bool,
            dataUpdatedHandler: @escaping (Bool) -> Void
        ) {
            self.title = title
            self.value = value
            self.dataUpdatedHandler = dataUpdatedHandler
        }
    }

    func configure(with configuration: Configuration) {
        self.configuration = configuration
        titleLabel.text = configuration.title
        toggle.isOn = configuration.value
    }

    private func reset() {
        configuration = nil
        titleLabel.text = nil
        toggle.isOn = false
    }
}

// MARK: - UITextFieldDelegate

extension ToggleTableViewCell {

    @objc func toggleValueChanged(_ sender: UISwitch) {
        configuration?.dataUpdatedHandler(sender.isOn)
    }
}

// MARK: - Setup UI

private extension ToggleTableViewCell {

    func setupUI() {
        selectionStyle = .none

        let pending = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        contentView.addSubview(titleLabel)
        contentView.addSubview(toggle)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: pending.top),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pending.left),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -pending.bottom),

            toggle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: pending.top),
            toggle.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: pending.left),
            toggle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -pending.bottom),
            toggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pending.right)
        ])
    }
}
