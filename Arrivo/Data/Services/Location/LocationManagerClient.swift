import CoreLocation

final class LocationManagerClient: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    weak var delegate: LocationManagerClientDelegate?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.pausesLocationUpdatesAutomatically = true
    }

    // MARK: Permissions

    func requestWhenInUsesAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

//    func requestAlwaysAuthorization() {
//        manager.requestAlwaysAuthorization()
//    }

    // MARK: Location

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    func requestCurrentLocation() {
        manager.requestLocation()
    }

    // MARK: Geofence

    func startMonitoring(region: CLCircularRegion) {
        manager.startMonitoring(for: region)
    }

    func stopMonitoring(id: String) {
        for region in manager.monitoredRegions {
            if region.identifier == id {
                manager.stopMonitoring(for: region)
            }
        }
    }

    func stopAllMonitoring() {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
    }

    func getCLCoordinateBy(id: String) -> CLLocationCoordinate2D? {
        guard
            let region = manager.monitoredRegions.first(where: { $0.identifier == id }),
            let circular = region as? CLCircularRegion
        else { return nil }

        return circular.center
    }

    func getMonitoringRegion(id: String) -> CLRegion? {
        manager.monitoredRegions.first { $0.identifier == id }
    }

    var monitoredRegions: Set<CLRegion> {
        manager.monitoredRegions
    }

    // MARK: Delegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authorized =
            manager.authorizationStatus == .authorizedAlways ||
            manager.authorizationStatus == .authorizedWhenInUse

        delegate?.didChangeAuthorization(isAuthorized: authorized)
    }

    func locationManager(
        _: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let last = locations.last {
            delegate?.didUpdate(location: last)
        }
    }

    func locationManager(
        _: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {
        let id = region.identifier

        let startedMonitoringsIDs = UserDefaults.standard.stringArray(forKey: "startedMonitoringsIDs") ?? []
        var newSMIs: [String] = []
        for newID in startedMonitoringsIDs {
            if id != newID {
                newSMIs.append(id)
            }
        }
        UserDefaults.standard.set(newSMIs, forKey: "startedMonitoringsIDs")

        guard let data = UserDefaults.standard.data(forKey: "oldMonitoringsCoordinate") else {
            delegate?.didEnterRegion()
            return
        }
        var oldData: [CoordinateModel] = []
        do {
            oldData = try JSONDecoder().decode([CoordinateModel].self, from: data)
        } catch {
            print("❌ Failed to load old monitorings:", error)
        }
        let circular = region as? CLCircularRegion
        if let circular {
            let newOldData = CoordinateModel(geoCoordinate: GeoCoordinate(circular.center))
            oldData.append(newOldData)
            do {
                let data = try JSONEncoder().encode(oldData)
                UserDefaults.standard.set(data, forKey: "oldMonitoringsCoordinate")
            } catch {
                print("❌ Failed to save old monitorings:", error)
            }
        }

        delegate?.didEnterRegion()
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error)
    }
}
