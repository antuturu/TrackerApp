//
//  TrackerViewController.swift
//  TrackerApp
//
//  Created by Александр Акимов on 13.02.2024.
//

import UIKit

protocol TrackerViewControllerDelegate: AnyObject {
    func createdTracker(tracker: Tracker, categoryTitle: String)
}

final class TrackerViewController: UIViewController {

    var categories: [TrackerCategory] = [
        TrackerCategory(
            title: "Уборка",
            trackers: [
                Tracker(
                    id: UUID(),
                    name: "Помыть посуду",
                    color: .systemGreen,
                    emoji: "🤡",
                    schedule: [WeekDayModel.friday]
                ),
                Tracker(
                    id: UUID(),
                    name: "Погладить одежду",
                    color: .systemBlue,
                    emoji: "👑",
                    schedule: []
                )
            ]

        ),
        TrackerCategory(
            title: "Сделать уроки",
            trackers: [
                Tracker(
                    id: UUID(),
                    name: "География",
                    color: .systemRed,
                    emoji: "🙊",
                    schedule: []
                )
            ]
        )
    ]
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = .init()

    @IBOutlet weak var trackersLabel: UILabel!
    @IBOutlet weak var addNewTrackerButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var emptyStackView: UIStackView!
    @IBOutlet weak var noSearchResultsStackView: UIStackView!
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(HeaderCellView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderCellView.reuseIdentifier)
        collectionView.backgroundColor = UIColor(named: "White")
        return collectionView
    }()

    private let searchBar: UISearchTextField = {
        let search = UISearchTextField()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.placeholder = "Поиск"
        search.font = UIFont.systemFont(ofSize: 17)
        search.addTarget(self, action: #selector(searchTextChanged), for: .allEvents)
        return search
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = Date()
        collectionView.dataSource = self
        collectionView.delegate = self
        configureConstraints()
        filterVisibleCategories(for: currentDate)
        emptyCollectionView()
        emptySearchCollectionView()
        collectionView.isHidden = true
        searchBar.delegate = self
        guard let color = UIColor(named: "Gray") else { return }
        addTopBorder(to: tabBarController?.tabBar, color: color, width: 1.0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func dateChanged(_ sender: Any) {
        currentDate = datePicker.date
        filterVisibleCategories(for: currentDate)
        if let datePickerContainerView = view.subviews.first(where: { String(describing: type(of: $0)).contains("UIDatePicker") }) {
            datePickerContainerView.subviews.forEach { subview in
                if let button = subview as? UIButton {
                    button.sendActions(for: .touchUpInside)
                }
            }
        }
    }

    @objc private func searchTextChanged() {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            filterVisibleCategories(for: currentDate)
            return
        }
        let filteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.name.localizedCaseInsensitiveContains(searchText) &&
                tracker.schedule.contains(WeekDayModel(rawValue: Calendar.current.component(.weekday, from: currentDate)) ?? .monday)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                title: category.title,
                trackers: filteredTrackers
            )
        }
        visibleCategories = filteredCategories.compactMap { $0 }
        if visibleCategories.isEmpty {
            showNoResultsImage()
            hideEmptyStateImage()
        } else {
            hideNoResultsImage()
            hideEmptyStateImage()
        }
        collectionView.reloadData()
    }

    @objc private func dismissKeyboard() {
            view.endEditing(true)
        }

    private func addTopBorder(to tabBar: UITabBar?, color: UIColor, width: CGFloat) {
        guard let tabBar = tabBar else { return }
        let topBorder = CALayer()
        topBorder.backgroundColor = color.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: width)
        tabBar.layer.addSublayer(topBorder)
    }

    private func configureConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @IBAction private func addNewTrackerTapped(_ sender: Any) {
        let trackerCreatingViewController = TrackerCreatingViewController()
        trackerCreatingViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerCreatingViewController)
        present(navigationController, animated: true)
    }

    private func isMatchRecord(model: TrackerRecord, with trackerId: UUID) -> Bool {
        return model.id == trackerId && Calendar.current.isDate(model.date, inSameDayAs: currentDate)
    }

    private func setEmptyStateVisibility(isHidden: Bool, for imageView: UIImageView, label: UILabel) {
        imageView.isHidden = isHidden
        label.isHidden = isHidden
    }

    private func emptyCollectionView() {
        if visibleCategories.isEmpty && searchBar.text?.isEmpty ?? true {
            showEmptyStateImage()
            hideNoResultsImage()
            collectionView.isHidden = true
        } else {
            hideEmptyStateImage()
            collectionView.isHidden = false
        }
    }

    private func emptySearchCollectionView() {
        if visibleCategories.isEmpty && !(searchBar.text?.isEmpty ?? true) {
            showNoResultsImage()
            hideEmptyStateImage()
        } else {
            hideNoResultsImage()
            collectionView.isHidden = false
        }
    }

    private func showEmptyStateImage() {
        collectionView.isHidden = true
        emptyStackView.isHidden = false
    }

    private func hideEmptyStateImage() {
        emptyStackView.isHidden = true
    }

    private func showNoResultsImage() {
        collectionView.isHidden = true
        noSearchResultsStackView.isHidden = false
    }

    private func hideNoResultsImage() {
        noSearchResultsStackView.isHidden = true
    }

    private func filterVisibleCategories(for selectedDate: Date) {
        let selectedWeekday = Calendar.current.component(.weekday, from: selectedDate)
        visibleCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(WeekDayModel(rawValue: selectedWeekday) ?? .monday)
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }

        collectionView.reloadData()

        emptyCollectionView()
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 148
        let interItemSpacing: CGFloat = 10
        let width = (collectionView.bounds.width - interItemSpacing) / 2
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView,
                                             viewForSupplementaryElementOfKind:
                                    UICollectionView.elementKindSectionHeader,
                                             at: indexPath)

        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trackers = visibleCategories[section].trackers
        return trackers.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                            for: indexPath)
                as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        let cellData = visibleCategories
        let tracker = cellData[indexPath.section].trackers[indexPath.row]
        let isCompleted = completedTrackers.contains {
            isMatchRecord(model: $0, with: tracker.id)
        }
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        cell.delegate = self
        cell.configure(for: cell, tracker: tracker,
                       isCompletedToday: isCompleted,
                       completedDays: completedDays,
                       indexPath: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                withReuseIdentifier: HeaderCellView.reuseIdentifier,
                                                for: indexPath) as? HeaderCellView else { return
            UICollectionReusableView() }
        let titleCategory = categories[indexPath.section].title
        view.configureHeader(title: titleCategory)
        return view
    }
}

extension TrackerViewController: TrackerViewControllerDelegate {
    func createdTracker(tracker: Tracker, categoryTitle: String) {
        categories.append(TrackerCategory(title: categoryTitle, trackers: [tracker]))
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerCollectionViewCellDelegate {
    func completeTracker(id: UUID) {
        guard currentDate <= Date() else {
            return
        }
        completedTrackers.append(TrackerRecord(id: id, date: currentDate))
        collectionView.reloadData()
    }

    func uncompleteTracker(id: UUID) {
        completedTrackers.removeAll { element in
            if (element.id == id &&  Calendar.current.isDate(element.date, equalTo: currentDate, toGranularity: .day)) {
                return true
            } else {
                return false
            }
        }
        collectionView.reloadData()
    }
}

// MARK: - UITextFieldDelegate

extension TrackerViewController: UISearchTextFieldDelegate {
    private func textFieldShouldReturn(_ textField: UISearchTextField) -> Bool {
        textField.resignFirstResponder()
        hideNoResultsImage()
        return true
    }
}
