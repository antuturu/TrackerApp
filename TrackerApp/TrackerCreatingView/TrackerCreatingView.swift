//
//  TrackerCreatingView.swift
//  TrackerApp
//
//  Created by Александр Акимов on 05.03.2024.
//

import UIKit

protocol TrackerCreatingViewControllerProtocol: AnyObject {
    func createTracker(tracker: Tracker, categoryTitle: String)
    func cancelCreateTracker()
}

// MARK: - UIViewController

final class TrackerCreatingViewController: UIViewController, TrackerCreatingViewControllerProtocol {

    weak var delegate: TrackerViewControllerDelegate?

    private let regularButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "Black [day]")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(regularButtonClicked), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = "Создание трекера"
        text.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        text.textColor = UIColor(named: "Black [day]")
        return text
    }()

    private let irregularButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "Black [day]")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(irregularButtonClicked), for: .touchUpInside)
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 12
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White")
        configureStackView()
        configureConstraints()
        navigationItem.titleView = titleLabel
    }

    @objc private func regularButtonClicked() {
        let regularViewController = TrackerCreatingRegularViewController()
        regularViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: regularViewController)
        present(navigationController, animated: true)
    }

    @objc private func irregularButtonClicked() {
        let irregularViewController = TrackerCreatingIrregularViewController()
        irregularViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: irregularViewController)
        present(navigationController, animated: true)
    }

    private func configureStackView() {
        stackView.addArrangedSubview(regularButton)
        stackView.addArrangedSubview(irregularButton)
    }

    private func configureConstraints() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 136)
        ])
    }

    func createTracker(tracker: Tracker, categoryTitle: String) {
        delegate?.createdTracker(tracker: tracker, categoryTitle: categoryTitle)
        dismiss(animated: true)
        cancelCreateTracker()
    }

    func cancelCreateTracker() {
        dismiss(animated: true)
    }
}
