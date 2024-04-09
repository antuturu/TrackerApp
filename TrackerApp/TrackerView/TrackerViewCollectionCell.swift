//
//  TrackerViewCollectionCell.swift
//  TrackerApp
//
//  Created by Александр Акимов on 01.03.2024.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func completeTracker(id: UUID)
    func uncompleteTracker(id: UUID)
    func deleteTracker(tracker: Tracker)
    func pinTracker(tracker: Tracker)
    func editTracker(tracker: Tracker, completedDays: Int)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    var isCompleted: Bool?
    var trackerID: UUID?
    var indexPath: IndexPath?
    var tracker: Tracker?
    var completedDays: Int?
    private var isPinned: Bool = false
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private let mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Задание"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.text = "Задание"
        label.textColor = UIColor(named: "Black [day]")
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let countButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.contentMode = .center
        button.addTarget(self, action: #selector(countButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let pinImage: UIImageView = {
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.image = UIImage(systemName: "pin.fill")
            image.image = image.image?.withAlignmentRectInsets(UIEdgeInsets(
                top: -6,
                left: -6,
                bottom: -6,
                right: -6)
            )
            image.tintColor = .white
            return image
        }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        configureConstraints()
    }
    
    func configure(for: UICollectionViewCell,
                   tracker: Tracker,
                   isCompletedToday: Bool,
                   completedDays: Int,
                   indexPath: IndexPath) {
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        mainView.backgroundColor = tracker.color
        countButton.backgroundColor = tracker.color
        updateCounterLabelText(completedDays: completedDays)
        self.completedDays = completedDays
        self.tracker = tracker
        self.isPinned = tracker.pinned
        self.trackerID = tracker.idTracker
        self.isCompleted = isCompletedToday
        self.indexPath = indexPath
        let image = isCompleted! ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        let imageButton = UIImageView(image: image)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        countButton.backgroundColor = isCompletedToday ? tracker.color.withAlphaComponent(0.3) : tracker.color
        titleLabel.backgroundColor = tracker.color
        for view in self.countButton.subviews {
            view.removeFromSuperview()
        }
        
        countButton.addSubview(imageButton)
        NSLayoutConstraint.activate([
            imageButton.centerXAnchor.constraint(equalTo: countButton.centerXAnchor),
            imageButton.centerYAnchor.constraint(equalTo: countButton.centerYAnchor)
        ])
        
        showPin()
    }
    
    @objc private func countButtonTapped() {
        guard let isCompleted = isCompleted,
              let trackerID = trackerID
        else {
            return
        }
        if isCompleted {
            delegate?.uncompleteTracker(id: trackerID)
        } else {
            self.delegate?.completeTracker(id: trackerID)
        }
    }
    
    private func addSubviews() {
        contentView.addSubview(mainView)
        contentView.addSubview(dayLabel)
        contentView.addSubview(countButton)
        mainView.backgroundColor = .green
        mainView.addSubview(emojiLabel)
        mainView.addSubview(titleLabel)
        mainView.addSubview(pinImage)
        let interaction = UIContextMenuInteraction(delegate: self)
        mainView.addInteraction(interaction)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -12),
            
            dayLabel.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 16),
            dayLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 12),
            dayLabel.heightAnchor.constraint(equalToConstant: 18),
            
            countButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            countButton.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 8),
            countButton.widthAnchor.constraint(equalToConstant: 34),
            countButton.heightAnchor.constraint(equalToConstant: 34),
            
            pinImage.widthAnchor.constraint(equalToConstant: 24),
            pinImage.heightAnchor.constraint(equalToConstant: 24),
            pinImage.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 12),
            pinImage.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -4)
        ])
    }
    
    private func showPin() {
            if self.isPinned {
                pinImage.isHidden = false
            } else {
                pinImage.isHidden = true
            }
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateCounterLabelText(completedDays: Int) {
        let formattedString = String.localizedStringWithFormat(
            NSLocalizedString("StringKey", comment: ""),
            completedDays
        )
        dayLabel.text = formattedString
    }
}

extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let tracker = tracker,
              let completedDays = completedDays
        else {
            return nil
        }

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in

                let pinAction = UIAction(title: self.isPinned ? NSLocalizedString("pinAction.titleRemove", comment: "") : NSLocalizedString("pinAction.title", comment: "")) { [weak self] _ in
                    let tracker = Tracker(idTracker: tracker.idTracker, name: "", color: .clear, colorString: "", emoji: "", schedule: [], pinned: tracker.pinned, selectedCategoryIndex: Int(), emojiIndex: Int(), colorIndex: Int())
                    self?.delegate?.pinTracker(tracker: tracker)
                }

                let editAction = UIAction(title: NSLocalizedString("editAction.title", comment: "")) { [weak self] _ in
                    let tracker = Tracker(idTracker: tracker.idTracker, name: tracker.name, color: tracker.color, colorString: tracker.colorString, emoji: tracker.emoji, schedule: tracker.schedule, pinned: tracker.pinned, selectedCategoryIndex: tracker.selectedCategoryIndex, emojiIndex: tracker.emojiIndex, colorIndex: tracker.colorIndex)
                    print(tracker)
                    self?.delegate?.editTracker(tracker: tracker, completedDays: completedDays)
                }

                let deleteAction = UIAction(title: NSLocalizedString("deleteAction.title", comment: ""), attributes: .destructive) { [weak self] _ in
                    let tracker = Tracker(idTracker: tracker.idTracker, name: "", color: .clear, colorString: "", emoji: "", schedule: [], pinned: false, selectedCategoryIndex: tracker.selectedCategoryIndex, emojiIndex: tracker.emojiIndex, colorIndex: tracker.colorIndex)
                    self?.delegate?.deleteTracker(tracker: tracker)
                }
                return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
            }
        )
    }
}
