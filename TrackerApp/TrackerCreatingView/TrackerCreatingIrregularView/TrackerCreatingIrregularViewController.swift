//
//  TrackerCreatingIrregularViewController.swift
//  TrackerApp
//
//  Created by Александр Акимов on 07.03.2024.
//

import UIKit

final class TrackerCreatingIrregularViewController: UIViewController {

    weak var delegate: TrackerCreatingViewControllerProtocol?

    private let dataForTableView = "Категория"
    private var selectedCategory = String()
    private var isCategorySelected: Bool = false
    private var isTextEntered: Bool = false
    private var isEmojiSelected: Bool = false
    private var selectedEmoji: Int?
    private var isColorSelected: Bool = false
    private var selectedColor: Int?
    private var emojiz: [String] = ["🙂", "😻", "🐶", "🌺",
                                    "❤️", "😱", "😇", "😡",
                                    "🥶", "🤔", "🙌", "🍔",
                                    "🥦", "🏓", "🥇", "🎸",
                                    "🏝️", "😪"]
    private var colors: [String] = ["Color selection 1",
                                    "Color selection 2",
                                    "Color selection 3",
                                    "Color selection 4",
                                    "Color selection 5",
                                    "Color selection 6",
                                    "Color selection 7",
                                    "Color selection 8",
                                    "Color selection 9",
                                    "Color selection 10",
                                    "Color selection 11",
                                    "Color selection 12",
                                    "Color selection 13",
                                    "Color selection 14",
                                    "Color selection 15",
                                    "Color selection 16",
                                    "Color selection 17",
                                    "Color selection 18"]
    private let textField: UITextField = {
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

    private let titleLabel: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = "Новое нерегулярное событие"
        text.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        text.textColor = UIColor(named: "Black [day]")
        return text
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "Background")
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
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
        button.layer.borderColor = UIColor(named: "Red")?.cgColor
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

    private let emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = false
        collectionView.register(
            EmojiColorCollectionViewCell.self,
            forCellWithReuseIdentifier: "Cell")
        collectionView.register(EmojiAndColorHeaderCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: EmojiAndColorHeaderCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White")
        configureView()
        configureConstraints()
        createButton.isEnabled = false
        createButtonActivation()
    }

    @objc private func pushCancelButton() {
        dismiss(animated: true)
    }

    @objc private func pushCreateButton() {
        let currentWeekday = Calendar.current.component(.weekday, from: Date())
        let newSchedule = ScheduleModel(day: WeekDayModel(rawValue: currentWeekday) ?? .sunday, isOn: true)
        let scheduleArray = [newSchedule]
        let weekdayArray = scheduleArray.map { $0.day }
        dismiss(animated: true)
        guard let color = selectedColor, let emoji = selectedEmoji else { return }
        let tracker = Tracker(id: UUID(),
                              name: textField.text ?? "",
                              color: UIColor(named: colors[color]) ?? .red,
                              emoji: emojiz[emoji],
                              schedule: weekdayArray)
        delegate?.createTracker(tracker: tracker, categoryTitle: selectedCategory)
    }

    @objc private func dismissKeyboard() {
            view.endEditing(true)
    }

    private func configureView() {
        navigationItem.titleView = titleLabel
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [textField,
         tableView,
         stackView
        ].forEach {
            contentView.addSubview($0)
        }
        contentView.addSubview(emojiCollectionView)
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),

            tableView.heightAnchor.constraint(equalToConstant: 75),
            tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),

            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 450),

            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0)
        ])
    }

    private func setSubTitle(_ subTitle: String, forCellAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ButtonCell else {
            return
        }
        cell.set(subText: subTitle)
    }

    private func updateCategory(_ category: String) {
        selectedCategory = category
        isCategorySelected = true
        setCategoryTitle(selectedCategory)
        createButtonActivation()
    }

    private func setCategoryTitle(_ category: String) {
        setSubTitle(category, forCellAt: IndexPath(row: 0, section: 0))
    }

    private func createButtonActivation() {
        print(isCategorySelected && (textField.text != nil) && isEmojiSelected && isColorSelected)
        if isCategorySelected && (textField.text != nil) && isEmojiSelected && isColorSelected {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "Black [day]")
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "Gray")
        }
    }
}

// MARK: - UITableViewDelegate

extension TrackerCreatingIrregularViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row == 0 else { return }
        let categoryViewController = CategoryAddViewController()
        categoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: categoryViewController)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension TrackerCreatingIrregularViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseIdentifier,
                                                       for: indexPath) as? ButtonCell else { return UITableViewCell() }
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(named: "Background")
        cell.titleLabel.text = dataForTableView
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITextFieldDelegate

extension TrackerCreatingIrregularViewController: UITextFieldDelegate {
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
        createButtonActivation()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - CategoryAddViewControllerDelegate

extension TrackerCreatingIrregularViewController: CategoryAddViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        updateCategory(category)
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerCreatingIrregularViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let selectedEmoji = selectedEmoji {
                let previousIndex = IndexPath(item: selectedEmoji, section: 0)
                if let cell = collectionView.cellForItem(at: previousIndex) as? EmojiColorCollectionViewCell {
                    print("уборка")
                    print(previousIndex)
                    cell.titleLabel.backgroundColor = .white
                }
            }
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiColorCollectionViewCell else { return }
            cell.titleLabel.backgroundColor = UIColor(named: "Gray")
            selectedEmoji = indexPath.row
            isEmojiSelected = true
        case 1:
            if let selectedColor = selectedColor {
                let previousIndex = IndexPath(item: selectedColor, section: 1)
                guard let cell = collectionView.cellForItem(at: previousIndex) as? EmojiColorCollectionViewCell else { return }
                print("уборка цвета")
                print(previousIndex)
                cell.layer.borderWidth = 0
            }
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiColorCollectionViewCell else { return }
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            cell.layer.borderColor = UIColor(named: colors[indexPath.row])?.cgColor
            cell.layer.borderWidth = 3
            isColorSelected = true
            selectedColor = indexPath.row
        default:
            print("ошибка ничего не выбрано")
        }
        createButtonActivation()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerCreatingIrregularViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emojiz.count
        }
        if section == 1 {
            return colors.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
            for: indexPath) as? EmojiColorCollectionViewCell else { return UICollectionViewCell() }
        if indexPath.section == 0 {
            let emoji = emojiz[indexPath.row]
            cell.titleLabel.text = emoji
        } else if indexPath.section == 1 {
            let color = UIColor(named: colors[indexPath.row])
            cell.titleLabel.backgroundColor = color
        }
        cell.titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: EmojiAndColorHeaderCell.reuseIdentifier,
            for: indexPath
        ) as? EmojiAndColorHeaderCell else { return UICollectionReusableView() }
        if indexPath.section == 0 {
            view.titleLabel.text = "Emoji"
        } else if indexPath.section == 1 {
            view.titleLabel.text = "Цвет"
        }
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerCreatingIrregularViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 40, right: 18)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
            let indexPath = IndexPath(row: 0, section: section)
            let headerView = self.collectionView(collectionView,
                                                 viewForSupplementaryElementOfKind:
                                                    UICollectionView.elementKindSectionHeader,
                                                 at: indexPath)
            return headerView.systemLayoutSizeFitting(
                CGSize(
                    width: collectionView.frame.width,
                    height: UIView.layoutFittingExpandedSize.height
                ),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
        }
}
