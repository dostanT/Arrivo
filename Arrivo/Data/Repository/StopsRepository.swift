//
//  StopsRepository.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 06.04.2026.
//

final class FileStopsRepository: StopsRepositoryProtocol {
    func loadStops(for city: CityStopsSource) async throws -> [Stop] {
        try await StopsFileLoader.load(from: city.rawValue)
    }
}
