//
//  CategoryAddView.swift
//  TrackerApp
//
//  Created by Александр Акимов on 09.03.2024.
//

import UIKit

protocol CategoryAddViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoryAddViewController: UIViewController {

    weak var delegate: CategoryAddViewControllerDelegate?
    private var dataForTableView: [String] = []
    private var selectedCategoryIndex: Int?

    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "Black [day]")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(pushAddCategoryButton), for: .touchUpInside)
        return button
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

    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "errorTracker")
        return image
    }()

    private let textNotFoundLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "Black [day]")
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White")
        configureView()
        configureConstraints()
    }

    @objc private func pushAddCategoryButton() {
        let newCategoryViewController = CreateNewCategoryViewController()
        newCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newCategoryViewController)
        present(navigationController, animated: true)
    }

    private func configureView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(addButton)
        view.addSubview(tableView)
        view.addSubview(imageView)
        view.addSubview(textNotFoundLabel)
    }

    private func configureConstraints() {
        navigationItem.title = "Категория"

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -24),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),

            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            textNotFoundLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            textNotFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func showEmptyStateImage() {
        imageView.isHidden = false
        textNotFoundLabel.isHidden = false
        tableView.isHidden = true
    }

    private func hideEmptyStateImage() {
        imageView.isHidden = true
        textNotFoundLabel.isHidden = true
        tableView.isHidden = false
    }

    private func updateEmptyStateVisibility() {
        if dataForTableView.isEmpty {
            showEmptyStateImage()
        } else {
            hideEmptyStateImage()
        }
    }
}

// MARK: - UITableViewDelegate

extension CategoryAddViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        selectedCategoryIndex = indexPath.row
        tableView.reloadData()

        let selectedCategory = dataForTableView[indexPath.row]
        delegate?.didSelectCategory(selectedCategory)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoryAddViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataForTableView.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellView.reuseIdentifier,
                                    for: indexPath) as? CustomCellView else { return UITableViewCell() }
        cell.textLabel?.text = dataForTableView[indexPath.row]
        cell.backgroundColor = UIColor(named: "Background")
        cell.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )

        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16.0

        if dataForTableView.count == 1 {
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

        if indexPath.row == selectedCategoryIndex {
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

// MARK: - NewCategoryViewControllerDelegate

extension CategoryAddViewController: CreateNewCategoryViewControllerDelegate {
    func didCreateCategory(_ category: String) {
        if !dataForTableView.contains(category) {
            dataForTableView.append(category)
            tableView.invalidateIntrinsicContentSize()
            tableView.layoutIfNeeded()
            tableView.reloadData()
            updateEmptyStateVisibility()
        }
    }

    func updatedCategoryList(_ categories: [String]) {
        dataForTableView = categories
        tableView.reloadData()
        updateEmptyStateVisibility()
    }
}
