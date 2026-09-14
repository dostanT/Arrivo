//
//  LocationManagerClientDelegate.swift
//  Arrivo
//

import CoreLocation

protocol LocationManagerClientDelegate: AnyObject {
    func didUpdate(location: CLLocation)
    func didEnterRegion()
    func didChangeAuthorization(isAuthorized: Bool)
}
