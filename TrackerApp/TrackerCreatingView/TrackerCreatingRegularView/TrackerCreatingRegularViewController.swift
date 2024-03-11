//
//  TrackerCreatingRegularViewController.swift
//  TrackerApp
//
//  Created by Александр Акимов on 07.03.2024.
//

import UIKit

//MARK: - UIViewController

final class TrackerCreatingRegularViewController: UIViewController {

    weak var delegate: TrackerCreatingViewControllerProtocol?

    private let dataForTableView = ["Категория", "Расписание"]
    private var selectedSchedule: [WeekDayModel] = []
    private var selectedCategory = String()
    private var emojiz: [String] = ["😶‍🌫️", "💩", "🧠"]
    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(named: "Background")
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.addLeftPadding(16)
        textField.placeholder = "Введите название трекера"
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.smartInsertDeleteType = .no
        return textField
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "Background")
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseIdentifier)
        return tableView
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "White")
        button.setTitleColor(UIColor(named: "Red"), for: .normal)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        let red = UIColor(named: "Red")
        button.layer.borderColor = red?.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(pushCancelButton), for: .touchUpInside)
        return button
    }()

    private let createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "Black [day]")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(pushCreateButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White")
        configureView()
        configureConstraints()
        createButton.isEnabled = false
    }

    @objc private func pushCreateButton() {
        guard let trackerName = textField.text else { return }
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: UIColor(named: "Blue") ?? .blue,
            emoji: emojiz.randomElement()!,
            schedule: selectedSchedule)
        delegate?.createTracker(tracker: newTracker, categoryTitle: selectedCategory)
        dismiss(animated: true)
    }

    @objc private func pushCancelButton() {
        dismiss(animated: true)
    }

    private func configureView() {
        view.addSubview(textField)
        view.addSubview(tableView)
        view.addSubview(stackView)
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func configureConstraints() {
        navigationItem.title = "Новая привычка"
        view.addSubview(textField)
        textField.delegate = self
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),

            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),

            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func updateCategory(_ category: String) {
        selectedCategory = category
        setSubTitle(category, forCellAt: IndexPath(row: 0, section: 0))
    }

    private func setSubTitle(_ subTitle: String?, forCellAt indexPath: IndexPath) {
            guard let cell = tableView.cellForRow(at: indexPath) as? ButtonCell else {
                return
            }
            cell.set(subText: subTitle)
        }
}

extension TrackerCreatingRegularViewController: ScheduleViewControllerDelegate {
    func updateScheduleInfo(_ selectedDays: [WeekDayModel]) {
        self.selectedSchedule = selectedDays
        let subText = selectedSchedule.map { $0.shortValue }.joined(separator: ", ")
        setSubTitle(subText, forCellAt: IndexPath(row: 1, section: 0))
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate

extension TrackerCreatingRegularViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let categoryViewController = CategoryAddViewController()
            categoryViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: categoryViewController)
            present(navigationController, animated: true)
        } else if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            present(navigationController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension TrackerCreatingRegularViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataForTableView.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseIdentifier,
                                                       for: indexPath) as? ButtonCell else { return UITableViewCell() }

        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(named: "Background")
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            cell.titleLabel.text = dataForTableView[indexPath.row]
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.titleLabel.text = dataForTableView[indexPath.row]
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITextFieldDelegate

extension TrackerCreatingRegularViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text, !text.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "Black [day]")
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "Gray")
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - CategoryViewControllerDelegate

extension TrackerCreatingRegularViewController: CategoryAddViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        updateCategory(category)
    }
}
