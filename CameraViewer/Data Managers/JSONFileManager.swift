//
//  JSONFileManager.swift
//  CameraViewer
//
//  Created by mani on 2019-10-28.
//

import Foundation

protocol JSONFileManager {
    associatedtype Element: Codable

    var fileName: String { get set }
    var pathToData: URL { get }

    func save(_ elements: [Element]) throws
    func read() throws -> [Element]
}

extension JSONFileManager {
    var pathToData: URL {
        return FileManager.default.pathToFile(filename: fileName)
    }

    func save(_ elements: [Element]) throws {
        try JSONDataManager<[Element]>().write(data: elements, to: pathToData)
    }

    func read() throws -> [Element] {
        var savedItems = [Element]()
        savedItems = try JSONDataManager<Element>().read(from: pathToData)
        return savedItems
    }
}
