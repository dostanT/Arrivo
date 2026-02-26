import MapKit
import CoreLocation

// MARK: - Domain/UseCase Implementations
final class DetectCityUseCaseImpl: DetectCityUseCase {
    func execute(for coordinate: CLLocationCoordinate2D) -> CityStopsSource? {
        CityBounds.regions.first { _, region in
            // Используем pure function вместо extension
            regionContains(coordinate, region: region)
        }?.key
    }
}

final class LoadStopsUseCaseImpl: LoadStopsUseCase {
    private let repository: StopsRepository
    
    init(repository: StopsRepository) {
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

final class FilterVisibleStopsUseCaseImpl: FilterVisibleStopsUseCase {
    func execute(
        stops: [Stop],
        grid: [GridKey: [Stop]],
        mapState: MapState,
        currentCity: CityStopsSource
    ) async -> [Stop] {
        guard !stops.isEmpty else { return [] }
        
        // Вычисляем все данные на MainActor ДО перехода в background
        let zoomLevel = ZoomLevel(from: mapState.span)
        let centerLocation = CLLocation(
            latitude: mapState.center.latitude,
            longitude: mapState.center.longitude
        )
        let cityRegion = CityBounds.regions[currentCity]
        
        // Копируем все данные в локальные константы
        let thinningStep = zoomLevel.thinningStep
        let shouldFilter = zoomLevel.shouldFilterByDistance
        let maxDistance = zoomLevel.maxDistanceMeters
        let relevantCells = GridCalculator.relevantCells(for: mapState.center, span: mapState.span)
        
        // Переходим в detached task
        return await Task.detached(priority: .userInitiated) {
            // Собираем остановки из релевантных ячеек
            var relevantStops: [Stop] = []
            for cell in relevantCells {
                if let stopsInCell = grid[cell] {
                    relevantStops.append(contentsOf: stopsInCell)
                }
            }
            
            // Фильтруем по городу, прореживанию и расстоянию
            let filtered = relevantStops.enumerated().compactMap { index, stop -> Stop? in
                // Проверка города с помощью pure function
                if let region = cityRegion {
                    if !regionContains(stop.coordinate, region: region) {
                        return nil
                    }
                }
                
                // Прореживание
                if index % thinningStep != 0 {
                    return nil
                }
                
                // Фильтрация по расстоянию
                if shouldFilter {
                    let stopLocation = CLLocation(
                        latitude: stop.coordinate.latitude,
                        longitude: stop.coordinate.longitude
                    )
                    let distance = centerLocation.distance(from: stopLocation)
                    if distance > maxDistance {
                        return nil
                    }
                }
                
                return stop
            }
            
            return filtered
        }.value
    }
}
