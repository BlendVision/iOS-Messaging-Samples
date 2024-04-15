//
//  TextFieldTableViewCell.swift
//  MessagingSDKSample
//
//  Created by Bing Kuo on 2024/1/24.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    
    private(set) var configuration: Configuration?

    private lazy var stackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillProportionally
        view.axis = .vertical
        view.spacing = 8
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    private lazy var textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.layer.borderColor = UIColor.red.cgColor
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.delegate = self
        return textField
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

extension TextFieldTableViewCell: CustomCell {
    
    typealias Configuration = CellConfiguration

    struct CellConfiguration: CustomCellConfiguration {
        let title: String
        let placeholder: String?
        let value: String?
        var valueUpdatedHandler: ((String?) -> Void)?

        init(
            title: String,
            placeholder: String? = nil,
            value: String? = nil,
            valueUpdatedHandler: ((String?) -> Void)? = nil
        ) {
            self.title = title
            self.placeholder = placeholder
            self.value = value
            self.valueUpdatedHandler = valueUpdatedHandler
        }
    }

    func configure(with configuration: Configuration) {
        self.configuration = configuration

        setupTitleLabel(configuration)
        setupTextField(configuration)
    }
}

extension TextFieldTableViewCell {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        configuration?.valueUpdatedHandler?(textField.text)
    }
}

// MARK: - Setup UI

private extension TextFieldTableViewCell {

    enum Constant {
        static let inset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        static let spacing = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }

    func setupUI() {
        selectionStyle = .none

        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constant.inset.top),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.inset.left),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constant.inset.bottom),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.inset.right)
        ])

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
    }

    func setupTitleLabel(_ configuration: Configuration) {
        titleLabel.text = configuration.title
    }

    func setupTextField(_ configuration: Configuration) {
        textField.placeholder = configuration.placeholder
        textField.text = configuration.value
    }
}

// MARK: - UITextFieldDelegate

extension TextFieldTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        configuration?.valueUpdatedHandler?(textField.text)
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        configuration?.valueUpdatedHandler?(textField.text)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
