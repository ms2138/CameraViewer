//
//  VideoStreamViewController.swift
//  CameraViewer
//
//  Created by mani on 2021-08-15.
//

import UIKit

class VideoStreamViewController: UIViewController {
    @IBOutlet weak var cameraView: CameraView!
    var videoStreamURL: URL? {
        willSet {
            if let url = newValue {
                if let cameraView = cameraView {
                    cameraView.loadVideo(from: url)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
