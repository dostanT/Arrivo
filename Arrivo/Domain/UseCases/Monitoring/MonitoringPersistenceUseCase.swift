//
//  MonitoringPersistenceUseCase.swift
//  Arrivo
//

import Foundation

protocol MonitoringPersistenceUseCase: Sendable {
    func loadStartedMonitoringIds() -> [String]
    func saveStartedMonitoringIds(_ ids: [String])
    func loadOldMonitorings() -> [CoordinateModel]
    func saveOldMonitorings(_ models: [CoordinateModel])
    func loadLastSelectedCoordinate() -> GeoCoordinate?
    func saveLastSelectedCoordinate(_ coordinate: GeoCoordinate)
}

private enum Keys {
    static let startedMonitoringsIDs = "startedMonitoringsIDs"
    static let oldMonitoringsCoordinate = "oldMonitoringsCoordinate"
    static let lastLat = "last_selected_lat"
    static let lastLon = "last_selected_lon"
}

final class MonitoringPersistenceUseCaseImpl: MonitoringPersistenceUseCase {
    private let storage: KeyValueStorageProtocol

    init(storage: KeyValueStorageProtocol) {
        self.storage = storage
    }

    func loadStartedMonitoringIds() -> [String] {
        storage.stringArray(forKey: Keys.startedMonitoringsIDs) ?? []
    }

    func saveStartedMonitoringIds(_ ids: [String]) {
        storage.set(ids, forKey: Keys.startedMonitoringsIDs)
    }

    func loadOldMonitorings() -> [CoordinateModel] {
        guard let data = storage.data(forKey: Keys.oldMonitoringsCoordinate) else {
            return []
        }
        return (try? JSONDecoder().decode([CoordinateModel].self, from: data)) ?? []
    }

    func saveOldMonitorings(_ models: [CoordinateModel]) {
        guard let data = try? JSONEncoder().encode(models) else { return }
        storage.set(data, forKey: Keys.oldMonitoringsCoordinate)
    }

    func loadLastSelectedCoordinate() -> GeoCoordinate? {
        guard let lat = storage.double(forKey: Keys.lastLat),
              let lon = storage.double(forKey: Keys.lastLon)
        else {
            return nil
        }
        return GeoCoordinate(latitude: lat, longitude: lon)
    }

    func saveLastSelectedCoordinate(_ coordinate: GeoCoordinate) {
        storage.set(coordinate.latitude, forKey: Keys.lastLat)
        storage.set(coordinate.longitude, forKey: Keys.lastLon)
    }
}
