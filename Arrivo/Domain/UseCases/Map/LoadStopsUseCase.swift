//
//  LoadStopsUseCase.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 06.04.2026.
//


protocol LoadStopsUseCase: Sendable {
    func execute(for city: CityStopsSource) async -> [Stop]
}

final class LoadStopsUseCaseImpl: LoadStopsUseCase {
    private let repository: StopsRepositoryProtocol

    init(repository: StopsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for city: CityStopsSource) async -> [Stop] {
        do {
            return try await repository.loadStops(for: city)
        } catch {
            print("❌ Ошибка загрузки остановок: \(error)")
            return []
        }
    }
}
