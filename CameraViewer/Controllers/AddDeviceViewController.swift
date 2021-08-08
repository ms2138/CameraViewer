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
