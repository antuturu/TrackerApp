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
    
    var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = .init()
    private var selectedFilterIndex: Int?
    
    private let trackerStore: TrackerStoreProtocol = TrackerStore()
    private let trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()
    private let trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    
    @IBOutlet weak var trackersLabel: UILabel!
    @IBOutlet weak var addNewTrackerButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var emptyStackView: UIStackView!
    @IBOutlet weak var emptyTitle: UILabel!
    @IBOutlet weak var noSearchResultTitle: UILabel!
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
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0)
        return collectionView
    }()
    
    private let searchBar: UISearchTextField = {
        let search = UISearchTextField()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.placeholder = NSLocalizedString("trackerViewController.serchPlaceholder", comment: "Search placeholder")
        search.font = UIFont.systemFont(ofSize: 17)
        search.addTarget(self, action: #selector(searchTextChanged), for: .allEvents)
        return search
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(named: "BackgroundDatePicker")
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        label.layer.zPosition = 10
        return label
    }()
    
    private var filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(named: "Blue")
        button.setTitle(NSLocalizedString("trackerViewController.filterButton", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        configureView()
        configureConstraints()
        emptyCollectionView()
        emptySearchCollectionView()
        updateDateLabelTitle(with: currentDate)
        collectionView.isHidden = true
        searchBar.delegate = self
        trackerStore.setDelegate(self)
        reloadData()
        guard let color = UIColor(named: "Gray") else { return }
        addTopBorder(to: tabBarController?.tabBar, color: color, width: 1.0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        currentDate = datePicker.date
        updateDateLabelTitle(with: currentDate)
        filterVisibleCategories(for: currentDate)
        selectedFilterIndex = nil
        collectionView.reloadData()
    }
    
    @objc private func filterButtonTapped() {
        let filterViewController = FiltersViewController()
        filterViewController.delegate = self
        filterViewController.selectedFilterIndex = self.selectedFilterIndex
        let navigationController = UINavigationController(rootViewController: filterViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func searchTextChanged() {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            selectedFilter(selectedFilterIndex ?? 0)
            return
        }
        let filteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.name.localizedCaseInsensitiveContains(searchText) &&
                tracker.schedule.contains(WeekDayModel(rawValue: Calendar.current.component(.weekday,
                                                                                            from: currentDate)) ?? .monday)
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
    
    @IBAction private func addNewTrackerTapped(_ sender: Any) {
        let trackerCreatingViewController = TrackerCreatingViewController()
        trackerCreatingViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerCreatingViewController)
        present(navigationController, animated: true)
    }
    
    private func addTopBorder(to tabBar: UITabBar?, color: UIColor, width: CGFloat) {
        guard let tabBar = tabBar else { return }
        let topBorder = CALayer()
        topBorder.backgroundColor = color.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: width)
        tabBar.layer.addSublayer(topBorder)
    }
    
    private func configureView() {
        [collectionView,
         searchBar,
         dateLabel,
         filterButton].forEach {
            view.addSubview($0)
        }
        trackersLabel.text = NSLocalizedString("trackerViewController.title", comment: "title on trackers page")
        emptyTitle.text = NSLocalizedString("trackerViewController.emptyTitle", comment: "title that shows when nothing to show")
        noSearchResultTitle.text = NSLocalizedString("trackerViewController.noSearchResultTitle", comment: "title that show when no search results")
        updateDateLabelTitle(with: currentDate)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            dateLabel.widthAnchor.constraint(equalToConstant: 77),
            dateLabel.heightAnchor.constraint(equalToConstant: 34),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: date)
    }
    
    private func updateDateLabelTitle(with date: Date) {
        let dateString = formattedDate(from: date)
        dateLabel.text = dateString
    }
    
    private func isMatchRecord(model: TrackerRecord, with trackerId: UUID) -> Bool {
        let day = DateFormatter()
        day.dateFormat = "dd.MM.yyyy"
        let currentDayString = formattedDate(from: currentDate)
        guard let formattedDay = day.date(from: currentDayString) else { return Bool() }
        return model.id == trackerId && Calendar.current.isDate(model.date, inSameDayAs: formattedDay)
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
        visibleCategories = []
        var pinnedCategories: [TrackerCategory] = []
        var nonPinnedCategories: [TrackerCategory] = []
        nonPinnedCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(WeekDayModel(rawValue: selectedWeekday) ?? .monday) && tracker.pinned == false
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        pinnedCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(WeekDayModel(rawValue: selectedWeekday) ?? .monday) && tracker.pinned != false
            }
            return TrackerCategory(title: NSLocalizedString("pinnedCategoryTitle", comment: ""), trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        visibleCategories.append(contentsOf: nonPinnedCategories)
        visibleCategories.insert(contentsOf: pinnedCategories, at: 0)
        collectionView.reloadData()
        emptyCollectionView()
    }
    
    func filterVisibleCategoriesNotCompleted() {
        visibleCategories = []
        var pinnedCategories: [TrackerCategory] = []
        var nonPinnedCategories: [TrackerCategory] = []
        nonPinnedCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return !completedTrackers.contains {
                    isMatchRecord(model: $0, with: tracker.idTracker)
                } && tracker.pinned == false
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        pinnedCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return !completedTrackers.contains {
                    isMatchRecord(model: $0, with: tracker.idTracker)
                } && tracker.pinned != false
            }
            return TrackerCategory(title: NSLocalizedString("pinnedCategoryTitle", comment: ""), trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        visibleCategories.append(contentsOf: nonPinnedCategories)
        visibleCategories.insert(contentsOf: pinnedCategories, at: 0)
        collectionView.reloadData()
        emptyCollectionView()
    }
    
    func filterVisibleCategoriesCompleted() {
        visibleCategories = []
        var pinnedCategories: [TrackerCategory] = []
        var nonPinnedCategories: [TrackerCategory] = []
        nonPinnedCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return completedTrackers.contains {
                    isMatchRecord(model: $0, with: tracker.idTracker)
                } && tracker.pinned == false
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        pinnedCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return completedTrackers.contains {
                    isMatchRecord(model: $0, with: tracker.idTracker)
                } && tracker.pinned != false
            }
            return TrackerCategory(title: NSLocalizedString("pinnedCategoryTitle", comment: ""), trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        visibleCategories.append(contentsOf: nonPinnedCategories)
        visibleCategories.insert(contentsOf: pinnedCategories, at: 0)
        collectionView.reloadData()
        emptyCollectionView()
    }
    
    func filterVisibleCategoriesAll() {
        visibleCategories = []
        var pinnedCategories: [TrackerCategory] = []
        var nonPinnedCategories: [TrackerCategory] = []
        nonPinnedCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.pinned == false
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        pinnedCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.pinned != false
            }
            return TrackerCategory(title: NSLocalizedString("pinnedCategoryTitle", comment: ""), trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        visibleCategories.append(contentsOf: nonPinnedCategories)
        visibleCategories.insert(contentsOf: pinnedCategories, at: 0)
        collectionView.reloadData()
        emptyCollectionView()
    }
    
    private func reloadData() {
        trackerCategoryStore.getCategories { [weak self] categories in
            self?.categories = categories
            self?.filterVisibleCategories(for: self?.currentDate ?? Date())
        }
        do {
            completedTrackers = try trackerRecordStore.fetchRecords()
        } catch {
            assertionFailure("Failed to get categories with \(error)")
        }
        selectedFilter(selectedFilterIndex ?? 1)
        UserDefaults.standard.set(completedTrackers.count, forKey: "Completed")
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
            isMatchRecord(model: $0, with: tracker.idTracker)
        }
        let completedDays = completedTrackers.filter { $0.id == tracker.idTracker }.count
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
        let titleCategory = visibleCategories[indexPath.section].title
        view.configureHeader(title: titleCategory)
        return view
    }
}

extension TrackerViewController: TrackerViewControllerDelegate {
    func createdTracker(tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker, toCategory: TrackerCategory(title: categoryTitle, trackers: []))
            categories.append(TrackerCategory(title: categoryTitle, trackers: [tracker]))
            filterVisibleCategories(for: currentDate)
            collectionView.reloadData()
            reloadData()
        } catch {
            print("Failed to add tracker to Core Data: \(error)")
        }
    }
}

extension TrackerViewController: TrackerCollectionViewCellDelegate {
    func editTracker(tracker: Tracker, completedDays: Int) {
        let editViewController = EditViewController()
        editViewController.delegate = self
        editViewController.tracker = tracker
        editViewController.completedDays = completedDays
        let navigationController = UINavigationController(rootViewController: editViewController)
        present(navigationController, animated: true)
    }
    
    func pinTracker(tracker: Tracker) {
        do {
            try trackerStore.pinTracker(tracker)
            reloadData()
            collectionView.reloadData()
        } catch {
            print("Failed to pin tracker: \(error)")
        }
    }
    
    func deleteTracker(tracker: Tracker) {
        let actionSheet: UIAlertController = {
            let alert = UIAlertController()
            alert.title = NSLocalizedString("deleteTrackerAlertAction.title", comment: "")
            return alert
        }()
        
        let action1 = UIAlertAction(title: NSLocalizedString("deleteTrackerAlertAction.apply", comment: ""), style: .destructive) { [weak self] _ in
            do {
                try self?.trackerStore.deleteTracker(tracker)
                self?.reloadData()
                self?.collectionView.reloadData()
            } catch {
                print("Failed to delete tracker: \(error)")
            }
        }
        let action2 = UIAlertAction(title: NSLocalizedString("deleteTrackerAlertAction.cancel", comment: ""), style: .cancel)
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        
        present(actionSheet, animated: true)
    }
    
    func completeTracker(id: UUID) {
        
        let day = DateFormatter()
        day.dateFormat = "dd.MM.yyyy"
        let currentDayString = formattedDate(from: currentDate)
        let Day = formattedDate(from: Date())
        guard let today = day.date(from: Day) else { return }
        guard let formattedDay = day.date(from: currentDayString) else { return }
        
        guard formattedDay <= today else {
            return
        }
        
        completedTrackers.append(TrackerRecord(id: id, date: formattedDay))
        try? trackerRecordStore.createRecord(id: id, date: formattedDay)
        collectionView.reloadData()
    }
    
    func uncompleteTracker(id: UUID) {
        let day = DateFormatter()
        day.dateFormat = "dd.MM.yyyy"
        let currentDayString = formattedDate(from: currentDate)
        guard let formattedDay = day.date(from: currentDayString) else { return }
        completedTrackers.removeAll {
            $0.id == id && Calendar.current.isDate($0.date, equalTo: formattedDay, toGranularity: .day)
        }
        try? trackerRecordStore.deleteRecord(id: id, date: formattedDay)
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

extension TrackerViewController: TrackerStoreDelegate {
    func trackerStoreDidUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            collectionView.insertSections(update.insertedSections)
            collectionView.insertItems(at: update.insertedIndexPaths)
        }
    }
}

extension TrackerViewController: FiltersViewControllerDelegate {
    func selectedFilter(_ selectedFilterIndex: Int) {
        switch selectedFilterIndex {
        case 0:
            filterVisibleCategoriesAll()
            self.selectedFilterIndex = 0
        case 1:
            filterVisibleCategories(for: Date())
            self.selectedFilterIndex = 1
        case 2:
            filterVisibleCategoriesCompleted()
            self.selectedFilterIndex = 2
        case 3:
            filterVisibleCategoriesNotCompleted()
            self.selectedFilterIndex = 3
        default:
            break
        }
    }
}

extension TrackerViewController: EditViewControllerDelegate {
    func editedTracker(tracker: Tracker, categoryTitle: String) {
        do{
            try trackerStore.editTracker(tracker, toCategory: TrackerCategory(title: categoryTitle, trackers: []))
            filterVisibleCategories(for: currentDate)
            collectionView.reloadData()
            reloadData()
        } catch {
            print("Fail to edit tracker \(error)")
        }
    }
}
