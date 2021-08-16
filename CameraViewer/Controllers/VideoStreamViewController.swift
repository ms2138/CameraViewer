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

        guard let url = videoStreamURL else { return }

        if let ipAddress = url.host {
            if let query = url.query?.split(separator: "&").filter({ $0.contains("channel") }).first {
                let channel = query.localizedCapitalized.split(separator: "=").joined(separator: " ")
                title = "\(ipAddress) - \(channel)"
            }
        }

        cameraView.textLabel.font = UIFont.systemFont(ofSize: 40.0)

        loadVideoStream(for: url)
    }
}

extension VideoStreamViewController {
    // MARK: Loading video and events

    func loadVideoStream(for url: URL) {
        cameraView.loadVideo(from: url)
    }
}

extension VideoStreamViewController {
    // MARK: IBActions

    @IBAction func close(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func handleTap(gesture: UITapGestureRecognizer) {
        if let hidden = navigationController?.isNavigationBarHidden {
            navigationController?.setNavigationBarHidden(!hidden, animated: true)
            navigationController?.setToolbarHidden(!hidden, animated: true)
        }
    }
}
