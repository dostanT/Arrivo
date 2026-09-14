//
//  SearchStopsUseCaseImpl.swift
//  Arrivo
//

final class SearchStopsUseCaseImpl: SearchStopsUseCase {
    private var engine: SearchEngine?

    func updateStops(_ stops: [Stop]) async {
        engine = await SearchEngine(stops: stops)
    }

    func search(query: String) async -> [Stop] {
        guard let engine else { return [] }
        return await engine.search(query: query)
    }
}
