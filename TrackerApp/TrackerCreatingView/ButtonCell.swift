//
//  ButtonCell.swift
//  TrackerApp
//
//  Created by Александр Акимов on 07.03.2024.
//

import UIKit

final class ButtonCell: UITableViewCell {

    static let reuseIdentifier = "ButtonCell"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(subText: String?) {
        if let subText = subText {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            let subTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "Gray")]

            let subAttributedString = NSMutableAttributedString(string: subText,
                                                                attributes: subTextAttributes
                                                                as [NSAttributedString.Key: Any])
            subAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                             value: paragraphStyle,
                                             range: NSRange(location: 0, length: subAttributedString.length))
            titleLabel.numberOfLines = 1
            subtitleLabel.numberOfLines = 1
            subtitleLabel.attributedText = subAttributedString
        } else {
            titleLabel.text = nil
            subtitleLabel.text = nil
        }
    }

    private func setupView() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])

        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}
