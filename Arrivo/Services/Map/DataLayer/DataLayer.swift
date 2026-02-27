//
//  DataLayer.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 09.02.2026.
//
import MapKit

// MARK: - Data/Repositories

protocol StopsRepository {
    func loadStops(for city: CityStopsSource) async throws -> [Stop]
}

// MARK: - Data/Services

enum CityBounds {
    static let regions: [CityStopsSource: MKCoordinateRegion] = [
        .astana: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.1694, longitude: 71.4491),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .almaty: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.2389, longitude: 76.8897),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .aktau: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.6350, longitude: 51.1680),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .aktobe: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.2839, longitude: 57.1670),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .atyrau: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 47.0945, longitude: 51.9230),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .karaganda: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.8060, longitude: 73.0850),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .kokshetau: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 53.2833, longitude: 69.3833),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .kostanaj: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 53.2198, longitude: 63.6354),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .pavlodar: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.2873, longitude: 76.9674),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .petropavlovsk: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 54.8728, longitude: 69.1430),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .semej: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.4111, longitude: 80.2275),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .shchuchinsk: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.9350, longitude: 70.1880),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .taldykorgan: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.0156, longitude: 78.3739),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .temirtau: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.0549, longitude: 72.9647),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
        .uralsk: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.2278, longitude: 51.3865),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ),
    ]
}

// MARK: - Data/FileLoader

enum StopsFileLoader {
    static func load(from filename: String) async throws -> [Stop] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "txt") else {
            throw FileError.fileNotFound(filename)
        }

        let content = try String(contentsOf: url, encoding: .utf8)

        // 1. Чистим мусор
        let cleaned = content
            .replacingOccurrences(of: "\r\n", with: ",")
            .replacingOccurrences(of: "\n", with: ",")
            .replacingOccurrences(of: "\r", with: ",")
            .replacingOccurrences(of: "\"", with: "")

        // 2. Режем по запятым
        let tokens = cleaned
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        var stops: [Stop] = []
        var i = 0

        // 3. Читаем тройками
        while i + 2 < tokens.count {
            let name = tokens[i]
            let latString = tokens[i + 1]
            let lonString = tokens[i + 2]

            if let lat = Double(latString),
               let lon = Double(lonString)
            {
                stops.append(
                    Stop(
                        id: "\(name)_\(lat)_\(lon)",
                        name: name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: lat,
                            longitude: lon
                        )
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

// MARK: - Data/Repository Implementation

final class FileStopsRepository: StopsRepository {
    func loadStops(for city: CityStopsSource) async throws -> [Stop] {
        try await StopsFileLoader.load(from: city.rawValue)
    }
}
