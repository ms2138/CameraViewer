//
//  UICollectionView+EXT.swift
//  CameraViewer
//
//  Created by mani on 2021-08-09.
//

import UIKit

extension UICollectionView {
    func deselectAllItems(animated: Bool) {
        indexPathsForSelectedItems?.forEach { deselectItem(at: $0, animated: true) }
    }
}
