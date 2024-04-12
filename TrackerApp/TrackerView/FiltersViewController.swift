//
//  FiltersViewController.swift
//  TrackerApp
//
//  Created by Александр Акимов on 09.04.2024.
//

import UIKit

protocol FiltersViewControllerDelegate {
    func selectedFilter(_ selectedFilterIndex: Int)
}

final class FiltersViewController: UIViewController {
    
    var delegate: FiltersViewControllerDelegate?
    var selectedFilterIndex: Int?
    private let filters = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные"]
    
    private let titleLabel: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = NSLocalizedString("categoryView.title", comment: "")
        text.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        text.textColor = UIColor(named: "Black [day]")
        return text
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.separatorStyle = .singleLine
        table.tableHeaderView = UIView()
        table.separatorColor = UIColor(named: "Gray")
        table.register(CustomCellView.self, forCellReuseIdentifier: CustomCellView.reuseIdentifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureConstraints()
    }
    
    private func configureView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.titleView = titleLabel
        view.backgroundColor = UIColor(named: "White")
        [tableView
        ].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 340)
        ])
    }
    
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedFilterIndex = indexPath.row
        tableView.reloadData()
        delegate?.selectedFilter(selectedFilterIndex ?? 0)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellView.reuseIdentifier,
                                                       for: indexPath) as? CustomCellView else { return UITableViewCell() }
        let filter = filters[indexPath.row]
        cell.textLabel?.text = filter
        cell.backgroundColor = UIColor(named: "Background")
        cell.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16.0
        
        if filters.count == 1 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner,
                                        .layerMaxXMinYCorner,
                                        .layerMinXMaxYCorner,
                                        .layerMaxXMaxYCorner]
        } else {
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
            if indexPath.row == 0 {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if indexPath.row == numberOfRows - 1 {
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.layer.maskedCorners = []
            }
        }
        
        if indexPath.row == selectedFilterIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}


