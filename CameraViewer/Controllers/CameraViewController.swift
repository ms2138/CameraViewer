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
