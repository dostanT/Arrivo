//
//  StopsFileLoader.swift
//  Arrivo
//

import Foundation

enum StopsFileLoader {
    static func load(from filename: String) async throws -> [Stop] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "txt") else {
            throw FileError.fileNotFound(filename)
        }

        let content = try String(contentsOf: url, encoding: .utf8)

        let cleaned = content
            .replacingOccurrences(of: "\r\n", with: ",")
            .replacingOccurrences(of: "\n", with: ",")
            .replacingOccurrences(of: "\r", with: ",")
            .replacingOccurrences(of: "\"", with: "")

        let tokens = cleaned
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        var stops: [Stop] = []
        var i = 0

        while i + 2 < tokens.count {
            let name = tokens[i]
            let latString = tokens[i + 1]
            let lonString = tokens[i + 2]

            if let lat = Double(latString),
               let lon = Double(lonString)
            {
                let geo = GeoCoordinate(latitude: lat, longitude: lon)
                stops.append(
                    Stop(
                        id: "\(name)_\(lat)_\(lon)",
                        name: String(name),
                        coordinate: geo
                    )
                )
            }

            i += 3
        }

        return stops
    }

    enum FileError: Error {
        case fileNotFound(String)
    }
}
