//
//  DahuaDevice.swift
//  CameraViewer
//
//  Created by mani on 2021-08-05.
//

import Foundation

struct DahuaDevice: Codable {
    var type: String
    var address: String
    var serial: String
    var channels: [Channel]
}
