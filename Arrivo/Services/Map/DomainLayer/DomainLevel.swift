//
//  DomainLevel.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 09.02.2026.
//
import CoreLocation
import MapKit

// MARK: - Domain/UseCases
protocol DetectCityUseCase {
    func execute(for coordinate: CLLocationCoordinate2D) -> CityStopsSource?
}

protocol LoadStopsUseCase {
    func execute(for city: CityStopsSource) async -> [Stop]
}

protocol FilterVisibleStopsUseCase {
    func execute(
        stops: [Stop],
        grid: [GridKey: [Stop]],
        mapState: MapState,
        currentCity: CityStopsSource
    ) async -> [Stop]
}




struct MapState: Sendable {
    let center: CLLocationCoordinate2D
    let span: MKCoordinateSpan
    
    func hasSignificantChanges(comparedTo other: MapState, threshold: Double = 0.001) -> Bool {
        let latDiff = abs(center.latitude - other.center.latitude)
        let lonDiff = abs(center.longitude - other.center.longitude)
        let spanDiff = abs(span.latitudeDelta - other.span.latitudeDelta)
        
        return latDiff > threshold || lonDiff > threshold || spanDiff > threshold
    }
}

// MARK: - Grid System
struct GridKey: Hashable, Sendable {
    let x: Int
    let y: Int
}

struct GridCalculator {
    static let defaultCellSize: Double = 0.02
    
    static func buildGrid(from stops: [Stop], cellSize: Double = defaultCellSize) -> [GridKey: [Stop]] {
        var grid: [GridKey: [Stop]] = [:]
        
        for stop in stops {
            let x = Int(stop.coordinate.latitude / cellSize)
            let y = Int(stop.coordinate.longitude / cellSize)
            let key = GridKey(x: x, y: y)
            grid[key, default: []].append(stop)
        }
        
        return grid
    }
    
    static func relevantCells(
        for center: CLLocationCoordinate2D,
        span: MKCoordinateSpan,
        cellSize: Double = defaultCellSize
    ) -> [GridKey] {
        let latRange = center.latitude - span.latitudeDelta/2 ... center.latitude + span.latitudeDelta/2
        let lonRange = center.longitude - span.longitudeDelta/2 ... center.longitude + span.longitudeDelta/2
        
        let minX = Int(latRange.lowerBound / cellSize)
        let maxX = Int(latRange.upperBound / cellSize)
        let minY = Int(lonRange.lowerBound / cellSize)
        let maxY = Int(lonRange.upperBound / cellSize)
        
        var cells: [GridKey] = []
        for x in minX...maxX {
            for y in minY...maxY {
                cells.append(GridKey(x: x, y: y))
            }
        }
        return cells
    }
}

// MARK: - Pure Functions for Region Checking
func regionContains(
    _ coordinate: CLLocationCoordinate2D,
    region: MKCoordinateRegion
) -> Bool {
    let latMin = region.center.latitude - region.span.latitudeDelta / 2
    let latMax = region.center.latitude + region.span.latitudeDelta / 2
    let lonMin = region.center.longitude - region.span.longitudeDelta / 2
    let lonMax = region.center.longitude + region.span.longitudeDelta / 2
    
    return coordinate.latitude >= latMin &&
           coordinate.latitude <= latMax &&
           coordinate.longitude >= lonMin &&
           coordinate.longitude <= lonMax
}

// MARK: - Zoom Level (Sendable, без MainActor)
enum ZoomLevel: Sendable {
    case city      // delta > 0.15
    case district  // delta 0.05-0.15
    case street    // delta < 0.05
    
    init(from span: MKCoordinateSpan) {
        let delta = span.latitudeDelta
        if delta < 0.05 {
            self = .street
        } else if delta < 0.15 {
            self = .district
        } else {
            self = .city
        }
    }
    
    var thinningStep: Int {
        switch self {
        case .city: return 10
        case .district: return 5
        case .street: return 1
        }
    }
    
    var shouldFilterByDistance: Bool {
        switch self {
        case .city, .district: return true
        case .street: return false
        }
    }
    
    var maxDistanceMeters: Double {
        switch self {
        case .city: return 20000
        case .district: return 5000
        case .street: return 1000
        }
    }
}
