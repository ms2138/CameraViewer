//
//  ONVIFProfile.swift
//  CameraViewer
//
//  Created by mani on 2019-09-22.
//

import Foundation

struct ONVIFProfile: Codable {
    let name: String
    let token: String
    let encoding: String
    let resolution: Resolution
    var streams: [URL]

    init(name: String, token: String, encoding: String, resolution: Resolution) {
        self.name = name
        self.token = token
        self.encoding = encoding
        self.resolution = resolution
        self.streams = [URL]()
    }

    mutating func add(stream: URL) {
        streams.append(stream)
    }
}

struct Resolution: Codable {
    let width: Int
    let height: Int
}
