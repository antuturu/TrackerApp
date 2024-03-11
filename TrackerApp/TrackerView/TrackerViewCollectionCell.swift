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
}

final class TrackerCollectionViewCell: UICollectionViewCell {

    var isCompleted: Bool?
    var trackerID: UUID?
    var indexPath: IndexPath?

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
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        mainView.backgroundColor = tracker.color
        countButton.backgroundColor = tracker.color
        updateCounterLabelText(completedDays: completedDays)
        self.trackerID = tracker.id
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
            countButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateCounterLabelText(completedDays: Int) {
        let remainder = completedDays % 100
        if (11...14).contains(remainder) {
            dayLabel.text = "\(completedDays) дней"
        } else {
            switch remainder % 10 {
            case 1:
                dayLabel.text = "\(completedDays) день"
            case 2...4:
                dayLabel.text = "\(completedDays) дня"
            default:
                dayLabel.text = "\(completedDays) дней"
            }
        }
    }
}
