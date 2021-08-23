//
//  JSONDataManager.swift
//  CameraViewer
//
//  Created by mani on 2019-10-28.
//

import Foundation

class JSONDataManager<T: Codable> {
    func write(data: T, to path: URL) throws {
        let encoder = JSONEncoder()
        let encodedFeeds = try encoder.encode(data)
        try encodedFeeds.write(to: path, options: .atomic)
    }

    func read(from path: URL) throws -> [T] {
        let decoder = JSONDecoder()
        let savedData = try Data(contentsOf: path)
        let decodedData = try decoder.decode([T].self, from: savedData)
        return decodedData
    }
}
