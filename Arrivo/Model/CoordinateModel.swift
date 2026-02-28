//
//  CoordinateModel.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 28.02.2026.
//

import CoreLocation

struct CoordinateModel: Identifiable, Codable, Hashable {
    let id: String
    let latitude: Double
    let longitude: Double
    var text: String = ""

    init(coordinate: CLLocationCoordinate2D) {
        id = UUID().uuidString
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
