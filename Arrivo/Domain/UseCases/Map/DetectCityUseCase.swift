//
//  DetectCityUseCase.swift
//  Arrivo
//

protocol DetectCityUseCase: Sendable {
    func execute(for coordinate: GeoCoordinate) -> CityStopsSource?
}

final class DetectCityUseCaseImpl: DetectCityUseCase {
    func execute(for coordinate: GeoCoordinate) -> CityStopsSource? {
        CityBounds.regions.first { _, region in
            regionContains(coordinate, region: region)
        }?.key
    }
}
