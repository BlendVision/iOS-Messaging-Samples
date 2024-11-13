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

    private lazy var hStackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillProportionally
        view.axis = .horizontal
        view.spacing = 20
        return view
    }()
    
    private lazy var vStackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fill
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var indicatorContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var indicatorImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .gray
        return view
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
        let clickHandler: (() -> Void)?
        
        init(title: String, value: String, clickHandler: (() -> Void)? = nil) {
            self.title = title
            self.value = value
            self.clickHandler = clickHandler
        }
    }

    func configure(with configuration: Configuration) {
        self.configuration = configuration
        titleLabel.text = configuration.title
        contentLabel.text = configuration.value
        indicatorContainerView.isHidden = (configuration.clickHandler == nil)
    }

    private func reset() {
        configuration = nil
        titleLabel.text = nil
        contentLabel.text = nil
        indicatorContainerView.isHidden = true
    }
}

// MARK: - Setup UI

private extension InfoTableViewCell {

    func setupUI() {
        selectionStyle = .none

        let pending = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        contentView.addSubview(hStackView)
        hStackView.addArrangedSubview(vStackView)
        hStackView.addArrangedSubview(indicatorContainerView)
        indicatorContainerView.addSubview(indicatorImageView)
        vStackView.addArrangedSubview(titleLabel)
        vStackView.addArrangedSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: pending.top),
            hStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pending.left),
            hStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pending.right),
            hStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -pending.bottom),
            
            indicatorImageView.leadingAnchor.constraint(equalTo: indicatorContainerView.leadingAnchor),
            indicatorImageView.trailingAnchor.constraint(equalTo: indicatorContainerView.trailingAnchor),
            indicatorImageView.centerYAnchor.constraint(equalTo: indicatorContainerView.centerYAnchor),
            indicatorImageView.widthAnchor.constraint(equalToConstant: 10)
        ])
        
        let gestrure = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(gestrure)
    }
    
    @objc private func didTap() {
        configuration?.clickHandler?()
    }
}
