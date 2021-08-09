//
//  AddDeviceManuallyViewController.swift
//  CameraViewer
//
//  Created by mani on 2021-08-08.
//

import UIKit

class AddDeviceManuallyViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var hostCell: TextInputCell!
    @IBOutlet weak var portCell: TextInputCell!
    @IBOutlet weak var usernameCell: TextInputCell!
    @IBOutlet weak var passwordCell: TextInputCell!
    private var cells = [TextInputCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupTextInputCells()

        hostCell.textField.becomeFirstResponder()
    }
}

private extension AddDeviceManuallyViewController {
    // MARK: - Setup

    func setupTextInputCells() {
        guard let textInputCells = tableView.cells as? [TextInputCell] else { return }
        cells = textInputCells

        for (index, cell) in cells.enumerated() {
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
            cell.textField.autocapitalizationType = .none
            cell.textField.tag = index
            if (index + 1) % cells.count == 0 {
                cell.textField.returnKeyType = .done
            } else {
                cell.textField.returnKeyType = .next
            }
        }

        hostCell.keyboardType = .URL

        portCell.keyboardType = .numbersAndPunctuation

        usernameCell.textField.textContentType = .username

        passwordCell.textField.textContentType = .password
        passwordCell.textField.isSecureTextEntry = true
    }
}

extension AddDeviceManuallyViewController {
    // MARK: - Text field changes

    @objc func textDidChange(sender: UITextField) {
        if sender.textColor == .red {
            if #available(iOS 13.0, *) {
                sender.textColor = .label
            } else {
                sender.textColor = .black
            }
        }
    }
}
