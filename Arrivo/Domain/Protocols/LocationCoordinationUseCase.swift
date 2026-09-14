//
//  LocationCoordinationUseCase.swift
//  Arrivo
//

protocol LocationCoordinationUseCase: Sendable {
    func authorizationUpdates() -> AsyncStream<Bool>
    func locationUpdates() -> AsyncStream<GeoCoordinate?>
    func requestWhenInUseAuthorization()
    func requestCurrentLocation()
    func coordinate(forMonitoringId id: String) -> GeoCoordinate?
    func monitoringCenter(forRegionId id: String) async -> GeoCoordinate?
    func startMonitoring(regionId: String, coordinate: GeoCoordinate, radiusMeters: Double) async
    func stopMonitoring(regionId: String) async
    func stopAllMonitoring() async
}
