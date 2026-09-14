//
//  GeoDistance.swift
//  Arrivo
//
import MapKit

enum GeoDistance {
    /// Great-circle distance in meters (Earth radius ≈ 6,371 km).
    static func meters(from a: GeoCoordinate, to b: GeoCoordinate) -> Double {
        let earthRadius = 6_371_000.0
        let lat1 = a.latitude * .pi / 180
        let lat2 = b.latitude * .pi / 180
        let deltaLat = (b.latitude - a.latitude) * .pi / 180
        let deltaLon = (b.longitude - a.longitude) * .pi / 180

        let sinHalfLat = sin(deltaLat / 2)
        let sinHalfLon = sin(deltaLon / 2)
        let h = sinHalfLat * sinHalfLat + cos(lat1) * cos(lat2) * sinHalfLon * sinHalfLon
        let c = 2 * atan2(sqrt(h), sqrt(1 - h))
        return earthRadius * c
    }
}
