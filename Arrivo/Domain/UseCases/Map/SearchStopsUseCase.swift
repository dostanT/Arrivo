//
//  SearchStopsUseCase.swift
//  Arrivo
//

protocol SearchStopsUseCase: Sendable {
    func updateStops(_ stops: [Stop]) async
    func search(query: String) async -> [Stop]
}
