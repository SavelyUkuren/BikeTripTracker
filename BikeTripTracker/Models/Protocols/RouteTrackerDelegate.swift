//
//  RouteTrackerDelegate.swift
//  BikeTripTracker
//
//  Created by savik on 15.05.2024.
//

import Foundation
import CoreLocation

protocol RouteTrackerDelegate: AnyObject {
    func locationUpdate(_ coordinates: [CLLocationCoordinate2D])
}

extension RouteTrackerDelegate {
    func didStart() {}
    func didStop() {}
    func didResume() {}
    func didPause() {}
}
