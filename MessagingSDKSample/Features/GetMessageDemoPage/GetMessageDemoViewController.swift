//
//  GetMessageDemoViewController.swift
//  MessagingSDKSample
//
//  Created by bingkuo on 2024/10/22.
//

import UIKit

class GetMessageDemoViewController: UIViewController {

    private let viewModel: GetMessageDemoViewModel
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: InfoTableViewCell.identifier)
        return tableView
    }()
    
    init(viewModel: GetMessageDemoViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindingViewModel()
    }
}

private extension GetMessageDemoViewController {
    func setupUI() {
        title = "Get Message Demo"
        
        view.backgroundColor = .white
    
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func bindingViewModel() {
        viewModel.reloadDataClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.showInteractionTypeSelectionPageClosure = { [weak self] types in
            DispatchQueue.main.async {
                let viewController = InteractionTypeSelectionViewController(items: types) { [weak self] types in
                    self?.viewModel.updateSelectedTypes(types)
                }
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension GetMessageDemoViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = viewModel.cellForRowAt(indexPath) else { return UITableViewCell() }
        
        switch data {
        case let .typeSelectionText(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.identifier) as? InfoTableViewCell {
                cell.configure(with: data)
                return cell
            }
        case let .submitButton(data):
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier) as? ButtonTableViewCell {
                cell.configure(with: data)
                return cell
            }
        case let .result(data):
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
