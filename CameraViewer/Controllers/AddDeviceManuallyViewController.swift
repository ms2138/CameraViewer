//
//  AddDeviceManuallyViewController.swift
//  CameraViewer
//
//  Created by mani on 2021-08-08.
//

import UIKit

class AddDeviceManuallyViewController: UITableViewController, UITextFieldDelegate {
    enum TableSection: Int {
        case host = 0, port, username, password
    }
    typealias Port = Int
    typealias Username = String
    typealias Password = String
    @IBOutlet weak var hostCell: TextInputCell!
    @IBOutlet weak var portCell: TextInputCell!
    @IBOutlet weak var usernameCell: TextInputCell!
    @IBOutlet weak var passwordCell: TextInputCell!
    private var cells = [TextInputCell]()
    var handler: ((URL, Port, Username, Password) -> Void)?

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
    // MARK: - IBAction

    @IBAction func done() {
        for cell in cells.reversed() {
            let textField = cell.textField
            let validator = Validator()

            switch textField.tag {
                case 0:
                    if textField.validate([validator.isURLValid]) == false {
                        handleTextfieldValidation(in: textField,
                                                  message: "Please enter a valid URL")
                    }
                case 1:
                    if textField.validate([validator.isPortNumberValid]) == false {
                        handleTextfieldValidation(in: textField,
                                                  message: "Please enter a valid Port")
                    }
                case 2:
                    if textField.validate([validator.isUsernameValid]) == false {
                        handleTextfieldValidation(in: textField,
                                                  message: "Please enter a valid username")
                    }
                default:
                    break
            }
        }

        if let host = hostCell.textField.text, let port = portCell.textField.text,
           let username = usernameCell.textField.text, let password = passwordCell.textField.text {
            if let url = URL(string: host), let port = Int(port) {
                handler?(url, port, username, password)
            }
        }
    }
}

extension AddDeviceManuallyViewController {
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tableSection = TableSection(rawValue: section) else { return nil }
        switch tableSection {
            case .host:
                return "Host"
            case .port:
                return "Port"
            case .username:
                return "Username"
            case .password:
                return "Password"
        }
    }
}

extension AddDeviceManuallyViewController {
    // MARK: - Text field validation and changes

    func handleTextfieldValidation(in textField: UITextField, message: String) {
        textField.text = ""
        let placeholderTextColor = UIColor(red: 236.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
        textField.attributedPlaceholder = NSAttributedString(string: message,
                                                             attributes:
                                                                [NSAttributedString.Key.foregroundColor: placeholderTextColor])
        textField.textColor = .red
        textField.shake()

        textField.becomeFirstResponder()
    }

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
