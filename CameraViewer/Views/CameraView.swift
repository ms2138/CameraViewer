//
//  CameraView.swift
//  CameraViewer
//
//  Created by mani on 2021-08-05.
//

import Foundation

class CameraView: UIView {
    let textLabel = UILabel(frame: .zero)
    let mediaPlayer = VLCMediaPlayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        mediaPlayer.drawable = self

        textLabel.text = "Loading video..."
        textLabel.font = UIFont.systemFont(ofSize: 18.0)
        textLabel.textColor = .white

        addSubview(textLabel)
    }
}
