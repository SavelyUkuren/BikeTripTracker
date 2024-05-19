//
//  RouteTrackerDelegate.swift
//  BikeTripTracker
//
//  Created by savik on 15.05.2024.
//

import Foundation
import CoreLocation

protocol RouteTrackerDelegate: AnyObject {
    func locationUpdate(_ locations: [LocationModel])
}

extension RouteTrackerDelegate {
    func didStart() {}
    func didStop() {}
    func didResume() {}
    func didPause() {}
}
