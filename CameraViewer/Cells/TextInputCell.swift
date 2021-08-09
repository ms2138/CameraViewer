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
}
