//
//  StopsRepository.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 06.04.2026.
//


protocol StopsRepositoryProtocol: Sendable {
    func loadStops(for city: CityStopsSource) async throws -> [Stop]
}
