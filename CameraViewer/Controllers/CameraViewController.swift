//
//  ViewController.swift
//  CameraViewer
//
//  Created by mani on 2021-08-03.
//

import UIKit

class CameraViewController: UICollectionViewController {
    private let reuseIdentifier = "CameraCell"

    private var videoStreams = [URL]()
    @IBOutlet weak var selectionModeButtonItem: UIBarButtonItem!
    private var deleteButtonItem: UIBarButtonItem!
    var isSelecting: Bool = false {
        didSet {
            collectionView.allowsMultipleSelection = isSelecting
            navigationController?.setToolbarHidden(!isSelecting, animated: true)

            updateInterfaceForSelectionMode()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

extension CameraViewController {
    // MARK: - Collection view data source

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return videoStreams.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! CameraCell

        let videoStream = videoStreams[indexPath.row]
        cell.displayCamera(for: videoStream)
        cell.checkmark.checked = cell.isSelected

        return cell
    }
}

extension CameraViewController {
    // MARK: - Item Selection

    @IBAction func toggleSelection() {
        if isSelecting == true {
            selectionModeButtonItem.title = "Select"
            collectionView.deselectAllItems(animated: true)
            isSelecting = false
        } else {
            selectionModeButtonItem.title = "Cancel"
            isSelecting = true
        }
    }

    func updateInterfaceForSelectionMode() {
        guard let selectedPaths = collectionView.indexPathsForSelectedItems else {
            return
        }

        let enableButtonItem = (selectedPaths.count > 0)
        deleteButtonItem.isEnabled = enableButtonItem

        switch selectedPaths.count {
            case let selectionCount where selectionCount == 1:
                title = "\(selectedPaths.count) item selected"
            case let selectionCount where selectionCount > 1:
                title = "\(selectedPaths.count) items selected"
            default:
                title = isSelecting ? "Select Items" : "Live View"
        }
    }
}

extension CameraViewController {
    // MARK: - Keychain

    func saveToKeychain(credentials: Credential, query: KeychainQueryable) {
        let keychainWrapper = KeychainWrapper(queryable: query)
        do {
            try keychainWrapper.save(password: credentials.password, for: credentials.username)
        } catch {
            debugLog("Failed to save credentials")
        }
    }

    func removeFromKeychain(query: KeychainQueryable) {
        let keychainWrapper = KeychainWrapper(queryable: query)
        do {
            try keychainWrapper.delete()
        } catch {
            debugLog("Failed to save credentials")
        }
    }

    func readFromKeychain(query: KeychainQueryable) -> (username: String, password: String)? {
        let keychainWrapper = KeychainWrapper(queryable: query)
        do {
            let account = try keychainWrapper.readAccount()
            return account
        } catch {
            debugLog("Failed to read credentials")
        }
        return nil
    }

    private func generatePasswordQueryable(from url: URL) -> RTSPPasswordQueryable? {
        if let server = url.host, let port = url.port {
            return RTSPPasswordQueryable(server: server, port: port, path: url.path)
        }
        return nil
    }
}

extension CameraViewController {
    // MARK: - Adding and deleting streams

    @objc func deleteSelectedItems() {
        if let selectedPaths = collectionView.indexPathsForSelectedItems {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
                self.deleteItems(at: selectedPaths)
                self.updateInterfaceForSelectionMode()
            }

            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)

            present(alertController, animated: true)
        }
    }

    func deleteItems(at indexPaths: [IndexPath]) {
        var deleteVideoStreams = [URL]()
        indexPaths.forEach { indexPath in
            deleteVideoStreams.append(videoStreams[indexPath.row])
        }

        videoStreams.removeElements(in: deleteVideoStreams)

        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: indexPaths)
        }, completion: nil)

        if videoStreams.count == 0 {
            toggleSelection()
        }
    }

    func add(stream: URL) {
        videoStreams.append(stream)

        videoStreams.sort { $0.absoluteString < $1.absoluteString }

        if let index = self.videoStreams.firstIndex(of: stream) {
            let indexPath = IndexPath(row: index, section: 0)
            self.collectionView.insertItems(at: [indexPath])
            self.collectionView.reloadItems(at: [indexPath])
        }
    }

    func getRTSPStreamURL(from host: String, credential: Credential, channel: String, streamType: String) -> URL? {
        let dahuaAPI = DahuaAPI(host: host,
                                username: credential.username,
                                password: credential.password)

        return dahuaAPI.getRTSPStreamURL(channel: channel, streamType: streamType)
    }
}

extension CameraViewController {
    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "showAddDevice":
                showAddDevice(for: segue)
            default:
                preconditionFailure("Segue identifier did not match")
        }
    }

    private func showAddDevice(for segue: UIStoryboardSegue) {
        guard let navController = segue.destination as? UINavigationController else { return }
        guard let topController = navController.topViewController else { return }
        guard let viewController = topController as? AddDeviceViewController else { return }
        viewController.deviceFilter = videoStreams

        viewController.handler = { [unowned self] (device, credential) in
            if let device = device {
                if let url = self.getRTSPStreamURL(from: device.address,
                                                   credential: credential,
                                                   channel: "0",
                                                   streamType: "0") {
                    if let keychainQuery = self.generatePasswordQueryable(from: url) {
                        self.saveToKeychain(credentials: credential, query: keychainQuery)
                    }
                }

                device.channels.forEach { channel in
                    if let url = self.getRTSPStreamURL(from: device.address,
                                                       credential: credential,
                                                       channel: channel.number,
                                                       streamType: "0") {

                        let dahuaQuery = DahuaQueryService(host: device.address,
                                                           username: credential.username,
                                                           password: credential.password)
                        // Make a call to getAutoFocusStatus to ensure that the channel is active
                        dahuaQuery.getAutoFocusStatus(for: channel.number, completion: { (_, error) in
                            if error == nil {
                                DispatchQueue.main.async {
                                    self.add(stream: url)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}
