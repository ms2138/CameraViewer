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
}
