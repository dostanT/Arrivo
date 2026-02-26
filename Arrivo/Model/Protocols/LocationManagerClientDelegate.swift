//
//  LocationManagerClientDelegate.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 07.02.2026.
//

import CoreLocation
protocol LocationManagerClientDelegate: AnyObject {
    func didUpdate(location: CLLocation)
    func didEnterRegion()
    func didChangeAuthorization(isAuthorized: Bool)
}
