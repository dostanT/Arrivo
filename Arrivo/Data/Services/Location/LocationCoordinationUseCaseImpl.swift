//
//  LocationCoordinationUseCaseImpl.swift
//  Arrivo
//

import CoreLocation
import Foundation

final class LocationCoordinationUseCaseImpl: LocationCoordinationUseCase, LocationManagerClientDelegate {
    private let client: LocationManagerClient
    private let facade: LocationFacade
    private let alarmScheduler: AlarmSchedulerProtocol

    private let authStream: AsyncStream<Bool>
    private let authContinuation: AsyncStream<Bool>.Continuation

    private let locationStream: AsyncStream<GeoCoordinate?>
    private let locationContinuation: AsyncStream<GeoCoordinate?>.Continuation

    init(
        client: LocationManagerClient,
        geofenceStore: GeofenceStore,
        alarmScheduler: AlarmSchedulerProtocol
    ) {
        self.client = client
        facade = LocationFacade(store: geofenceStore, locationClient: client)
        self.alarmScheduler = alarmScheduler

        var authContinuation: AsyncStream<Bool>.Continuation!
        authStream = AsyncStream<Bool> { authContinuation = $0 }
        self.authContinuation = authContinuation

        var locationContinuation: AsyncStream<GeoCoordinate?>.Continuation!
        locationStream = AsyncStream<GeoCoordinate?> { locationContinuation = $0 }
        self.locationContinuation = locationContinuation

        client.delegate = self
    }

    func authorizationUpdates() -> AsyncStream<Bool> {
        authStream
    }

    func locationUpdates() -> AsyncStream<GeoCoordinate?> {
        locationStream
    }

    func requestWhenInUseAuthorization() {
        client.requestWhenInUsesAuthorization()
    }

    func requestCurrentLocation() {
        client.requestCurrentLocation()
    }

    func coordinate(forMonitoringId id: String) -> GeoCoordinate? {
        guard let cl = client.getCLCoordinateBy(id: id) else { return nil }
        return GeoCoordinate(cl)
    }

    func monitoringCenter(forRegionId id: String) async -> GeoCoordinate? {
        let region = await MainActor.run {
            client.getMonitoringRegion(id: id)
        }
        return (region as? CLCircularRegion).map { GeoCoordinate($0.center) }
    }

    func startMonitoring(regionId: String, coordinate: GeoCoordinate, radiusMeters: Double) async {
        await facade.startMonitoring(
            coordinate: coordinate.clCoordinate,
            radius: radiusMeters,
            id: regionId
        )
    }

    func stopMonitoring(regionId: String) async {
        await facade.stopMonitoring(id: regionId)
    }

    func stopAllMonitoring() async {
        await facade.stopMonitoring()
    }

    // MARK: - LocationManagerClientDelegate

    func didUpdate(location: CLLocation) {
        let geo = GeoCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        locationContinuation.yield(geo)
    }

    func didEnterRegion() {
        Task {
            await facade.didEnterRegion { [alarmScheduler] in
                Task {
                    await alarmScheduler.scheduleAlarm(durationSeconds: 1, label: "")
                }
            }
        }
    }

    func didChangeAuthorization(isAuthorized: Bool) {
        authContinuation.yield(isAuthorized)
    }
}
