//
//  Stop.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 07.02.2026.
//
import CoreLocation

struct Stop: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D

    // ⚡️ Предрассчитанное поле для быстрого поиска
    let normalizedName: String

    init(id: String, name: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.normalizedName = String(name.lowercased().sorted())
    }
}
