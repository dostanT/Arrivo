//
//  LocationFacade.swift
//  NuvuCollection
//
//  Created by Dostan Turlybek on 04.02.2026.
//
import CoreLocation

actor LocationFacade {

    private let store: GeofenceStore
    private let locationClient: LocationManagerClient
    

    init(
        store: GeofenceStore,
        locationClient: LocationManagerClient
    ) {
        self.store = store
        self.locationClient = locationClient
    }

    func startMonitoring(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, id: String) async  {
        let region = CLCircularRegion(
            center: coordinate,
            radius: 400,
            identifier: id
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false

        await MainActor.run {
            locationClient.startMonitoring(region: region)
        }
        Task {
            await store.save(coordinate: coordinate)
        }
    }
    
    func getMonitoringRegion(id: String) async -> CLRegion? {
        await MainActor.run {
            locationClient.getMonitoringRegion(id: id)
        }
    }
    
    func stopMonitoring(id: String) async {
        await MainActor.run {
            locationClient.stopMonitoring(id: id)
        }
        Task { await store.clear() }
    }

    func stopMonitoring() async {
        await MainActor.run {
            locationClient.stopAllMonitoring()
        }
        Task { await store.clear() }
    }

    func didEnterRegion(
        onComplete: @Sendable @escaping () -> Void
    ) async {
        await MainActor.run {
            onComplete()
        }
        await stopMonitoring()
    }

}
