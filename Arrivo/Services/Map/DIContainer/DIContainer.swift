//
//  DIContainer.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 09.02.2026.
//

// MARK: - DI Container

enum DependencyContainer {
    static func makeMapViewModel(locationService: LocationViewModel) -> MapViewModel {
        let repository = FileStopsRepository()
        let loadStopsUseCase = LoadStopsUseCaseImpl(repository: repository)
        let filterStopsUseCase = FilterVisibleStopsUseCaseImpl()
        let detectCityUseCase = DetectCityUseCaseImpl()

        return MapViewModel(
            locationService: locationService,
            loadStopsUseCase: loadStopsUseCase,
            filterStopsUseCase: filterStopsUseCase,
            detectCityUseCase: detectCityUseCase
        )
    }
}
