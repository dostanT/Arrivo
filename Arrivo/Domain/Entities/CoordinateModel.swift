//
//  CoordinateModel.swift
//  Arrivo
//
import Foundation
struct CoordinateModel: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let latitude: Double
    let longitude: Double
    var text: String = ""

    init(geoCoordinate: GeoCoordinate) {
        id = UUID().uuidString
        latitude = geoCoordinate.latitude
        longitude = geoCoordinate.longitude
    }
}
