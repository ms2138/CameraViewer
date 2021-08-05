//
//  ONVIFDevice.swift
//  CameraViewer
//
//  Created by mani on 2019-09-15.
//

import Foundation

struct ONVIFDevice: Codable {
    let manufacturer: String
    let model: String
    let firmwareVersion: String
    let serialNumber: String
    let hardwareID: String
    var profiles: [ONVIFProfile]

    init(manufacturer: String, model: String, firmwareVersion: String, serialNumber: String, hardwareID: String) {
        self.manufacturer = manufacturer
        self.model = model
        self.firmwareVersion = firmwareVersion
        self.serialNumber = serialNumber
        self.hardwareID = hardwareID
        self.profiles = [ONVIFProfile]()
    }
}

extension ONVIFDevice {
    mutating func add(profile: ONVIFProfile) {
        profiles.append(profile)
    }

    mutating func add(profiles: [ONVIFProfile]) {
        self.profiles.append(contentsOf: profiles)
    }

    mutating func removeProfile(at index: Int) {
        guard index > 0 || index < profiles.count else { return }
        profiles.remove(at: index)
    }

    mutating func removeAllProfiles() {
        profiles.removeAll()
    }
}

extension ONVIFDevice: Equatable {
    static func == (lhs: ONVIFDevice, rhs: ONVIFDevice) -> Bool {
        return lhs.serialNumber == rhs.serialNumber
    }
}
