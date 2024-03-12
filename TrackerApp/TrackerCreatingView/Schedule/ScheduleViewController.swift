//
//  ScheduleViewController.swift
//  TrackerApp
//
//  Created by Александр Акимов on 10.03.2024.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func updateScheduleInfo(_ selectedDays: [WeekDayModel])
}

// MARK: - UIViewController

final class ScheduleViewController: UIViewController {

    weak var delegate: ScheduleViewControllerDelegate?

    private var selectedSchedule: [WeekDayModel] = []

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView()
        tableView.separatorColor = UIColor(named: "Gray")
        tableView.register(CustomCellView.self, forCellReuseIdentifier: CustomCellView.reuseIdentifier)
        return tableView
    }()

    private let titleLabel: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = "Расписание"
        text.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        text.textColor = UIColor(named: "Black [day]")
        return text
    }()

    private let doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "Black [day]")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(pushDoneButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "White")
        navigationItem.hidesBackButton = true
        setupView()
        setupConstraints()
    }

    @objc private func pushDoneButton() {
        switchStatus()
        delegate?.updateScheduleInfo(selectedSchedule)
        dismiss(animated: true)
    }

    private func setupView() {
        view.addSubview(tableView)
        view.addSubview(doneButton)
        navigationItem.titleView = titleLabel
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 525),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -16),
            doneButton.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor,
                                            constant: 24),
            doneButton.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 47)
        ])
    }

    private func switchStatus() {
        for (index, weekDayModel) in WeekDayModel.allCases.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            guard let switchView = cell?.accessoryView as? UISwitch else {return}

            if switchView.isOn {
                selectedSchedule.append(weekDayModel)
            } else {
                selectedSchedule.removeAll { $0 == weekDayModel }
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDayModel.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellView.reuseIdentifier,
                                    for: indexPath) as? CustomCellView else { return UITableViewCell()}
        cell.backgroundColor = UIColor(named: "Background")
        cell.textLabel?.text = WeekDayModel.allCases[indexPath.row].value
        let switchButton = UISwitch(frame: .zero)
        switchButton.setOn(false, animated: true)
        switchButton.onTintColor = UIColor(named: "Blue")
        switchButton.tag = indexPath.row
        cell.accessoryView = switchButton
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}
