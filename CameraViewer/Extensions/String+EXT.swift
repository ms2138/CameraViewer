//
//  String+EXT.swift
//  CameraViewer
//
//  Created by mani on 2021-08-05.
//

import Foundation

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func removeAllWhitespacesAndNewlines() {
        return removeAll { $0.isNewline || $0.isWhitespace }
    }
}

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
