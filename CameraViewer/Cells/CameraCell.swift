//
//  CameraCell.swift
//  CameraViewer
//
//  Created by mani on 2021-08-05.
//

import Foundation

class CameraCell: UICollectionViewCell {
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var checkmark: DTCheckMarkView!

    override var isSelected: Bool {
        didSet {
            checkmark.checked = isSelected
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        checkmark.checked = false
    }
}
