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
