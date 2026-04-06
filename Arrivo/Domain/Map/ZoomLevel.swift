//
//  ZoomLevel.swift
//  Arrivo
//

enum ZoomLevel: Sendable {
    case noFilter
    case city
    case district
    case street

    init(fromLatitudeDelta delta: Double) {
        if delta < 0.07 {
            self = .street
        } else if delta < 0.17 {
            self = .district
        } else if delta < 2.7 {
            self = .city
        } else {
            self = .noFilter
        }
    }

    var thinningStep: Int {
        switch self {
        case .noFilter: return 1
        case .city: return 10
        case .district: return 5
        case .street: return 1
        }
    }

    var shouldFilterByDistance: Bool {
        switch self {
        case .city, .district, .noFilter: return true
        case .street: return false
        }
    }

    var maxDistanceMeters: Double {
        switch self {
        case .noFilter: return 100_000
        case .city: return 20000
        case .district: return 5000
        case .street: return 1000
        }
    }
}
