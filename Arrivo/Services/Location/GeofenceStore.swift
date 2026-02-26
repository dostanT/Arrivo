import Foundation
import CoreLocation

actor GeofenceStore {

    private let latKey = "monitoring_latitude"
    private let lonKey = "monitoring_longitude"
    private let dateKey = "monitoring_started_at"

    func save(coordinate: CLLocationCoordinate2D) {
        UserDefaults.standard.set(coordinate.latitude, forKey: latKey)
        UserDefaults.standard.set(coordinate.longitude, forKey: lonKey)
        UserDefaults.standard.set(Date(), forKey: dateKey)
    }
    

    func clear() {
        UserDefaults.standard.removeObject(forKey: latKey)
        UserDefaults.standard.removeObject(forKey: lonKey)
        UserDefaults.standard.removeObject(forKey: dateKey)
    }

    func hasSavedRegion() -> Bool {
        let lat = UserDefaults.standard.double(forKey: latKey)
        let lon = UserDefaults.standard.double(forKey: lonKey)
        return lat != 0 && lon != 0
    }
}
