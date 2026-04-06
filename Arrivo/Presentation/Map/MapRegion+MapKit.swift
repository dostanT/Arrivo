//
//  MapRegion+MapKit.swift
//  Arrivo
//

import MapKit

extension MapRegion {
    init(mkRegion: MKCoordinateRegion) {
        center = GeoCoordinate(
            latitude: mkRegion.center.latitude,
            longitude: mkRegion.center.longitude
        )
        latitudeDelta = mkRegion.span.latitudeDelta
        longitudeDelta = mkRegion.span.longitudeDelta
    }

    var mkCoordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }
}
