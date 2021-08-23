//
//  ViewController.swift
//  CameraViewer
//
//  Created by mani on 2021-08-03.
//

import UIKit

class CameraViewController: UICollectionViewController, JSONFileManager {
    typealias Element = URL

    private let reuseIdentifier = "CameraCell"

    internal var fileName = "Streams.json"
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

        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self

        deleteButtonItem = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(deleteSelectedItems))
        deleteButtonItem.isEnabled = false

        setToolbarItems([deleteButtonItem], animated: true)
    }


}

private extension CameraViewController {
    // MARK: - Save and read data

    @objc func saveVideoStreams() {
        do {
            let unauthenticatedStreams = self.videoStreams.compactMap { url -> URL? in
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.user = nil
                components?.password = nil
                return components?.url
            }
            try self.save(unauthenticatedStreams)
        } catch {
            debugLog("Failed to save data")
        }
    }

    func readVideoStreams() {
        do {
            self.videoStreams = try read().compactMap { [unowned self] url -> URL? in
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if let keychainQuery = self.generatePasswordQueryable(from: url),
                   let credential = self.readFromKeychain(query: keychainQuery) {
                    components?.user = credential.username
                    components?.password = credential.password
                }
                return components?.url
            }
        } catch {
            debugLog("Failed to read data")
        }
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
    // MARK: - Collection view delegate

    override func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isSelecting else { return }

        updateInterfaceForSelectionMode()
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard isSelecting else { return }

        updateInterfaceForSelectionMode()
    }
}

extension CameraViewController: UICollectionViewDelegateFlowLayout {
    // MARK: - Collection view flow layout delegate

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellDimensions = CGSize(width: view.frame.width / 2,
                                    height: view.frame.width / 2)
        return cellDimensions
    }
}

extension CameraViewController: UICollectionViewDragDelegate {
    // MARK: - Collection view drag delegate

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        let url = videoStreams[indexPath.row]

        let itemProvider = NSItemProvider(object: url as NSURL)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}

extension CameraViewController: UICollectionViewDropDelegate {
    // MARK: - Collection view drop delegate

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }

        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else {
                return
            }

            collectionView.performBatchUpdates({
                let toMoveStream = videoStreams.remove(at: sourceIndexPath.row)
                videoStreams.insert(toMoveStream, at: destinationIndexPath.row)

                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: { _ in
                coordinator.drop(dropItem.dragItem,
                                 toItemAt: destinationIndexPath)
            })
        }
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
}

extension CameraViewController {
    // MARK: - Content container

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
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

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showVideoStream" && isSelecting == true {
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "showAddDevice":
                showAddDevice(for: segue)
            case "showVideoStream":
                showVideoStream(for: segue)
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

    private func showVideoStream(for segue: UIStoryboardSegue) {
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems,
           let selectedItem = selectedIndexPaths.first {
            collectionView.deselectItem(at: selectedItem, animated: false)
            guard let navController = segue.destination as? UINavigationController else { return }
            guard let videoStreamViewController = navController.topViewController as?
                    VideoStreamViewController else { return }
            let authorizedStream = videoStreams[selectedItem.row]
            videoStreamViewController.videoStreamURL = authorizedStream
        }
    }
}
