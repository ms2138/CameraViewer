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

    let backgroundView = DTTableBackgroundView(frame: .zero)
    private var discoveredDevices = [ONVIFDiscovery]()
    private lazy var queryService = ONVIFQueryService(credential: ONVIFCredential(username: "",
                                                                                  password: ""))
    var handler: ((DahuaDevice?, Credential) -> Void)?

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

extension AddDeviceViewController {
    // MARK: - Create and find devices

    private func performDeviceDiscovery(filter: [URL]? = nil) {
        let hosts = filter?.compactMap { $0.host }

        getDevice { [weak self] (device) in
            guard let weakSelf = self else { return }

            DispatchQueue.main.async {

                if hosts?.contains(device.ipAddress) == true {
                    return
                }

                weakSelf.discoveredDevices.append(device)
                weakSelf.discoveredDevices.sort { $0.ipAddress < $1.ipAddress }
                weakSelf.tableView.reloadSections(IndexSet(integer: 0), with: .fade)

                if weakSelf.discoveredDevices.count == 0 {
                    weakSelf.backgroundView.stopLoadingOperation()
                }
            }
        }
    }

    func createDevice(from host: String, username: String, password: String,
                      completion: @escaping (DahuaDevice?, Credential) -> Void) {
        let dahuaQuery = DahuaQueryService(host: host,
                                           username: username,
                                           password: password)
        let credential = Credential(username: username, password: password)

        // Get device name
        dahuaQuery.getType { [weak self] (deviceType, error) in
            guard let weakSelf = self else { return }
            if let deviceType = deviceType {
                // Get serial number
                dahuaQuery.getSerialNumber(completion: { (serialNumber, _) in
                    if let serialNumber = serialNumber {
                        // Get device channel titles
                        dahuaQuery.getChannel(completion: { (channels, _) in
                            if let channels = channels {
                                let device = DahuaDevice(type: deviceType,
                                                         address: host,
                                                         serial: serialNumber,
                                                         channels: channels)
                                DispatchQueue.main.async {
                                    completion(device, credential)
                                }
                            }
                        })
                    }
                })
            } else {
                if let error = error {
                    DispatchQueue.main.async {
                        weakSelf.showErrorAlertController(error.localizedDescription)
                    }
                }
            }
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

extension AddDeviceViewController {
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tableSection = TableSection(rawValue: indexPath.section) {
            if tableSection == .devices {
                if discoveredDevices.count == 0 { return }
                showAuthenticationController { [weak self] (username, password) in
                    guard let weakSelf = self else { return }
                    let discoveredDevice = weakSelf.discoveredDevices[indexPath.row]

                    if let username = username, let password = password {
                        weakSelf.createDevice(from: discoveredDevice.ipAddress,
                                              username: username,
                                              password: password,
                                              completion: { (device, credential) in
                                                weakSelf.dismiss(animated: true) {
                                                    weakSelf.handler?(device, credential)
                                                }
                                              })
                    }
                }
            } else if tableSection == .addDevice {
                performSegue(withIdentifier: "showAddDeviceManually", sender: self)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
