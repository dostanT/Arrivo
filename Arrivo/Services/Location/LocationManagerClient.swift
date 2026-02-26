import CoreLocation

final class LocationManagerClient: NSObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    weak var delegate: LocationManagerClientDelegate?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestWhenInUsesAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func startMonitoring(region: CLCircularRegion) {
        manager.startMonitoring(for: region)
    }
    
    func stopMonitoring(id: String) { 
        manager.monitoredRegions.forEach { region in
            print(region)
            if region.identifier == id {
                manager.stopMonitoring(for: region)
            }
        }
    }

    func stopAllMonitoring() {
        manager.monitoredRegions.forEach {
            manager.stopMonitoring(for: $0)
        }
    }
    
    func getMonitoringRegion(id: String) -> CLRegion? {
        manager.monitoredRegions.first { $0.identifier == id }
    }

    var monitoredRegions: Set<CLRegion> {
        manager.monitoredRegions
    }

    // MARK: Delegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authorized = manager.authorizationStatus == .authorizedAlways ||
                         manager.authorizationStatus == .authorizedWhenInUse
        delegate?.didChangeAuthorization(isAuthorized: authorized)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let last = locations.last {
            delegate?.didUpdate(location: last)
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.didEnterRegion()
    }
}



