//
//  DTCheckMarkView.swift
//  CameraViewer
//
//  Created by mani on 2021-08-05.
//

import UIKit

class DTCheckMarkView: UIView {
    enum DTCheckMarkStyle: UInt {
        case openCircle
        case grayedOut
    }

    var checked: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    var checkMarkStyle: DTCheckMarkStyle = .grayedOut {
        didSet {
            setNeedsDisplay()
        }
    }

}
