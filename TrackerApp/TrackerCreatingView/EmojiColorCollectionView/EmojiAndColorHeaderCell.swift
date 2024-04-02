//
//  EmojiAndColorHeaderCell.swift
//  TrackerApp
//
//  Created by Александр Акимов on 19.03.2024.
//

import UIKit

final class EmojiAndColorHeaderCell: UICollectionReusableView {

    static let reuseIdentifier = "EmojiAndColorSupplementaryView"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "Black [day]")
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
