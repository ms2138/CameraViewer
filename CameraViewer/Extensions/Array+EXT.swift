//
//  Array+EXT.swift
//  CameraViewer
//
//  Created by mani on 2021-08-10.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        }
    }

    mutating func removeElements(in collection: [Element]) {
        collection.forEach { remove(element: $0) }
    }
}
