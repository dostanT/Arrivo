//
//  CityBounds.swift
//  Arrivo
//

enum CityBounds {
    static let regions: [CityStopsSource: MapRegion] = [
        .astana: MapRegion(
            center: GeoCoordinate(latitude: 51.1694, longitude: 71.4491),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .almaty: MapRegion(
            center: GeoCoordinate(latitude: 43.2389, longitude: 76.8897),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .aktau: MapRegion(
            center: GeoCoordinate(latitude: 43.6350, longitude: 51.1680),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .aktobe: MapRegion(
            center: GeoCoordinate(latitude: 50.2839, longitude: 57.1670),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .atyrau: MapRegion(
            center: GeoCoordinate(latitude: 47.0945, longitude: 51.9230),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .karaganda: MapRegion(
            center: GeoCoordinate(latitude: 49.8060, longitude: 73.0850),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .kokshetau: MapRegion(
            center: GeoCoordinate(latitude: 53.2833, longitude: 69.3833),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .kostanaj: MapRegion(
            center: GeoCoordinate(latitude: 53.2198, longitude: 63.6354),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .pavlodar: MapRegion(
            center: GeoCoordinate(latitude: 52.2873, longitude: 76.9674),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .petropavlovsk: MapRegion(
            center: GeoCoordinate(latitude: 54.8728, longitude: 69.1430),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .semej: MapRegion(
            center: GeoCoordinate(latitude: 50.4111, longitude: 80.2275),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .shchuchinsk: MapRegion(
            center: GeoCoordinate(latitude: 52.9350, longitude: 70.1880),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .taldykorgan: MapRegion(
            center: GeoCoordinate(latitude: 45.0156, longitude: 78.3739),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
        .uralsk: MapRegion(
            center: GeoCoordinate(latitude: 51.2278, longitude: 51.3865),
            latitudeDelta: 1.0,
            longitudeDelta: 1.0
        ),
    ]
}
