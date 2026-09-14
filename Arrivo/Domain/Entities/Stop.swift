//
//  Stop.swift
//  Arrivo
//

struct Stop: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let coordinate: GeoCoordinate

    /// Precomputed for search ranking.
    let normalizedName: String

    init(id: String, name: String, coordinate: GeoCoordinate) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        normalizedName = String(name.lowercased().sorted())
    }
}
