//
//  EventCell.swift
//  CameraViewer
//
//  Created by mani on 2021-08-18.
//

import UIKit

class EventCell: UITableViewCell {
    private let stackView: UIStackView
    let timeLabel: UILabel
    override var backgroundColor: UIColor? {
        willSet {
            contentView.backgroundColor = newValue
            timeLabel.backgroundColor = newValue
        }
    }
    var selectedColor: UIColor? {
        willSet {
            let view = UIView()
            view.backgroundColor = newValue
            selectedBackgroundView = view
        }
    }
    var timeLabelFont: UIFont? {
        willSet {
            timeLabel.font = newValue
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        timeLabel = UILabel(frame: .zero)
        stackView = UIStackView(arrangedSubviews: [timeLabel])

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        timeLabel = UILabel(frame: .zero)
        stackView = UIStackView(arrangedSubviews: [timeLabel])

        super.init(coder: aDecoder)

        initialize()
    }

    private func initialize() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        contentView.addSubview(stackView)

        timeLabel.text = "Label"
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        let margins = self.layoutMarginsGuide

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: margins.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
    }
}
