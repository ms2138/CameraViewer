//
//  TextInputCell.swift
//  CameraViewer
//
//  Created by mani on 2021-08-08.
//

import UIKit

class TextInputCell: UITableViewCell {
    let textField: UITextField

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        textField = UITextField()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        textField = UITextField()

        super.init(coder: aDecoder)

        initialize()
    }

    private func initialize() {
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(textField)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let margins = self.layoutMarginsGuide

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
    }
}
