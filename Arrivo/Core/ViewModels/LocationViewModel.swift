//
//  LocationViewModel.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 07.02.2026.
//
import Combine
import CoreLocation

@MainActor
final class LocationViewModel: ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var isAuthorized = false
    @Published var isMonitoringActive = false

    private let facade: LocationFacade
    private let client: LocationManagerClient
    private let alarmVM: ShudelerProtocol

    init() {
        let client = LocationManagerClient()
        let facade = LocationFacade(
            store: GeofenceStore(),
            locationClient: client
        )

        self.client = client
        self.facade = facade
        if #available(iOS 26.0, *) {
            alarmVM = AlarmViewModel()
        } else {
            alarmVM = NotificationAlarmViewModel()
        }
        client.delegate = self
        requestWhenInUsesAuthorization()
    }

    func getMonitoringRegion(id: String) async -> CLRegion? {
        await facade.getMonitoringRegion(id: id)
    }

    func requestWhenInUsesAuthorization() {
        client.requestWhenInUsesAuthorization()
    }

    func requestPermission() {
        client.requestAlwaysAuthorization()
    }

    func startMonitoring(at coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, id: String) {
        requestPermission()
        Task {
            await facade.startMonitoring(coordinate: coordinate, radius: radius, id: id)
            isMonitoringActive = true
        }
    }

    func stopMonitoringById(id: String) {
        Task {
            await facade.stopMonitoring(id: id)
        }
    }

    func stopMonitoring() {
        Task {
            await facade.stopMonitoring()
            isMonitoringActive = false
        }
    }
}

extension LocationViewModel: LocationManagerClientDelegate {
    func didUpdate(location: CLLocation) {
        currentLocation = location
    }

    nonisolated func schudleAlarm() {
        Task {
            await alarmVM.scheduleAlarm(with: 1)
        }
    }

    func didEnterRegion() {
        Task { await facade.didEnterRegion { [weak self] in
            self?.schudleAlarm()
        }}
        isMonitoringActive = false
    }

    func didChangeAuthorization(isAuthorized: Bool) {
        self.isAuthorized = isAuthorized
        if isAuthorized {
            client.startUpdatingLocation()
        }
    }
}
