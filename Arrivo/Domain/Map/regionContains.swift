//
//  regionContains.swift
//  Arrivo
//

func regionContains(_ coordinate: GeoCoordinate, region: MapRegion) -> Bool {
    let latMin = region.center.latitude - region.latitudeDelta / 2
    let latMax = region.center.latitude + region.latitudeDelta / 2
    let lonMin = region.center.longitude - region.longitudeDelta / 2
    let lonMax = region.center.longitude + region.longitudeDelta / 2

    return coordinate.latitude >= latMin &&
        coordinate.latitude <= latMax &&
        coordinate.longitude >= lonMin &&
        coordinate.longitude <= lonMax
}
