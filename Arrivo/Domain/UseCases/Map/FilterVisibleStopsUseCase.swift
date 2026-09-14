//
//  FilterVisibleStopsUseCase.swift
//  Arrivo
//

protocol FilterVisibleStopsUseCase: Sendable {
    func execute(
        stops: [Stop],
        grid: [GridKey: [Stop]],
        mapRegion: MapRegion,
        currentCity: CityStopsSource
    ) async -> [Stop]
}

final class FilterVisibleStopsUseCaseImpl: FilterVisibleStopsUseCase {
    func execute(
        stops: [Stop],
        grid: [GridKey: [Stop]],
        mapRegion: MapRegion,
        currentCity: CityStopsSource
    ) async -> [Stop] {
        guard !stops.isEmpty else { return [] }

        let zoomLevel = ZoomLevel(fromLatitudeDelta: mapRegion.latitudeDelta)
        if zoomLevel == .noFilter {
            return []
        }

        let center = mapRegion.center
        let cityRegion = CityBounds.regions[currentCity]

        let thinningStep = zoomLevel.thinningStep
        let shouldFilter = zoomLevel.shouldFilterByDistance
        let maxDistance = zoomLevel.maxDistanceMeters
        let relevantCells = GridCalculator.relevantCells(
            for: center,
            latitudeDelta: mapRegion.latitudeDelta,
            longitudeDelta: mapRegion.longitudeDelta
        )

        return await Task.detached(priority: .userInitiated) {
            var relevantStops: [Stop] = []
            for cell in relevantCells {
                if let stopsInCell = grid[cell] {
                    relevantStops.append(contentsOf: stopsInCell)
                }
            }

            return relevantStops.enumerated().compactMap { index, stop -> Stop? in
                if let region = cityRegion {
                    if !regionContains(stop.coordinate, region: region) {
                        return nil
                    }
                }

                if index % thinningStep != 0 {
                    return nil
                }

                if shouldFilter {
                    let distance = GeoDistance.meters(from: center, to: stop.coordinate)
                    if distance > maxDistance {
                        return nil
                    }
                }

                return stop
            }
        }.value
    }
}
