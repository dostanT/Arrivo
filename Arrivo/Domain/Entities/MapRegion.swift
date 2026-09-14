//
//  MapRegion.swift
//  Arrivo
//

struct MapRegion: Equatable, Sendable {
    var center: GeoCoordinate
    var latitudeDelta: Double
    var longitudeDelta: Double

    func hasSignificantChanges(comparedTo other: MapRegion, threshold: Double = 0.001) -> Bool {
        let latDiff = abs(center.latitude - other.center.latitude)
        let lonDiff = abs(center.longitude - other.center.longitude)
        let spanDiff = abs(latitudeDelta - other.latitudeDelta)
        return latDiff > threshold || lonDiff > threshold || spanDiff > threshold
    }

    static let defaultAstana = MapRegion(
        center: GeoCoordinate(latitude: 51.1694, longitude: 71.4491),
        latitudeDelta: MapSpanConstants.defaultLatitudeDelta,
        longitudeDelta: MapSpanConstants.defaultLongitudeDelta
    )
}
