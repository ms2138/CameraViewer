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
