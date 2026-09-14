//
//  FileStorageService.swift
//  Arrivo
//

import Foundation

actor FileStorageService {
    private let fileManager = FileManager.default

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func save<T: Codable>(_ object: T, to fileName: String) throws {
        let url = documentsDirectory.appendingPathComponent(fileName)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }

    func load<T: Codable>(from fileName: String) throws -> T {
        let url = documentsDirectory.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: url.path) else {
            throw NSError(domain: "File not found", code: 404)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
