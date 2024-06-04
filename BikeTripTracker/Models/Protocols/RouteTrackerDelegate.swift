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
    func errorOccured(msg: String)
    func didStart()
    func didStop()
}

extension RouteTrackerDelegate {
    func didResume() {}
    func didPause() {}
}
