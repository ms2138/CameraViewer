//
//  AddDeviceViewController.swift
//  CameraViewer
//
//  Created by mani on 2021-08-07.
//

import UIKit

class AddDeviceViewController: UITableViewController {
    enum TableSection: Int {
        case devices = 0, addDevice
    }
    enum SectionName: String {
        case devices = "Devices"
        case addDevice = "Add Device"
    }
    
    private var discoveredDevices = [ONVIFDiscovery]()
    private lazy var queryService = ONVIFQueryService(credential: ONVIFCredential(username: "",
                                                                                  password: ""))

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension AddDeviceViewController {
    // MARK: - IBAction methods

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension AddDeviceViewController {
    // MARK: - ONVIF Queries

    func getDevice(completion: @escaping (ONVIFDiscovery) -> Void) {
        do {
            try queryService.performONVIFDiscovery { (discoveredDevice, error) in
                if let error = error {
                    debugLog("Error: \(error)")
                }
                if let discoveredDevice = discoveredDevice {
                    completion(discoveredDevice)
                }
            }
        } catch {
            debugLog("Failed to perform UDP broadcast")
        }
    }
}

private extension AddDeviceViewController {
    // MARK: - Authentication and Alerts

    func showAuthenticationController(completion: @escaping (String?, String?) -> Void) {
        let alertController = UIAlertController(title: "Authentication Required", message: nil, preferredStyle: .alert)
        let notificationCenter = NotificationCenter.default

        var token: Any?

        let authenticateAction = UIAlertAction(title: "Authenticate", style: .default) { (_) in
            let usernameTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField

            notificationCenter.removeObserver(token!)

            completion(usernameTextField.text, passwordTextField.text)
        }
        authenticateAction.isEnabled = false

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            notificationCenter.removeObserver(token!)
            completion(nil, nil)
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "Username"

            token = notificationCenter.addObserver(forName: UITextField.textDidChangeNotification,
                                                   object: textField,
                                                   queue: OperationQueue.main) { (_) in
                authenticateAction.isEnabled = textField.text != ""
            }
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }

        alertController.addAction(authenticateAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    func showErrorAlertController(_ title: String) {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

extension AddDeviceViewController {
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
                case .devices:
                    if discoveredDevices.count > 0 {
                        return discoveredDevices.count
                    } else {
                        return 1
                    }
                case .addDevice:
                    return 1
            }

        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseIdentifier = "DeviceCell"

        if indexPath.section == 1 {
            reuseIdentifier = "AddDeviceCell"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        if indexPath.section == 0 {
            if discoveredDevices.count > 0 {
                let device = discoveredDevices[indexPath.row]
                cell.textLabel?.text = device.model
                cell.detailTextLabel?.text = device.ipAddress
                cell.isUserInteractionEnabled = true
            } else {
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.text = "No devices found"
                cell.isUserInteractionEnabled = false
            }
        } else {
            cell.textLabel?.text = "Add Manually..."
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let tableSection = TableSection(rawValue: section) {
            if tableSection == .devices {
                return SectionName.devices.rawValue
            } else if tableSection == .addDevice {
                return SectionName.addDevice.rawValue
            }
        }
        return nil
    }
}
