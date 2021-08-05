//
//  ONVIFDiscovery.swift
//  CameraViewer
//
//  Created by mani on 2019-09-22.
//

import Foundation

struct ONVIFDiscovery {
    let model: String
    let ipAddress: String
    let deviceService: URL
}

extension ONVIFDiscovery: Equatable {
    static func == (lhs: ONVIFDiscovery, rhs: ONVIFDiscovery) -> Bool {
        return lhs.ipAddress == rhs.ipAddress
    }
}
