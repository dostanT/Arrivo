//
//  FindNearestStopUseCase.swift
//  Arrivo
//

protocol FindNearestStopUseCase: Sendable {
    func execute(stops: [Stop], center: GeoCoordinate) -> Stop?
}

final class FindNearestStopUseCaseImpl: FindNearestStopUseCase {
    func execute(stops: [Stop], center: GeoCoordinate) -> Stop? {
        stops.min(by: { a, b in
            GeoDistance.meters(from: a.coordinate, to: center) < GeoDistance.meters(from: b.coordinate, to: center)
        })
    }
}
