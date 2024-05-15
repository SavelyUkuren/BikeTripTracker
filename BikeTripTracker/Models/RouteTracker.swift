//
//  RouteTracker.swift
//  BikeTripTracker
//
//  Created by savik on 15.05.2024.
//

import Foundation
import CoreLocation
import MapKit

class RouteTracker: NSObject {
    static var shared = RouteTracker()
    
    var speedMeasureUnit: SpeedMeasureUnit = .kilometersPerHour
    var speed: CLLocationSpeed {
        guard let speed = locationManager.location?.speed else { return 0 }
        guard speed > 0 else { return 0 }
        let result = speedMeasureUnit == .metersPerSecond ? speed : speed * 3.6
        if result > maxSpeed { maxSpeed = result }
        return result
    }
    var maxSpeed: CLLocationSpeed = 0
    
    weak var delegate: RouteTrackerDelegate?
    
    private(set) var state: TrackerState = .idle
    private(set) var locationManager = CLLocationManager()
    private(set) var coordinates: [CLLocationCoordinate2D] = []
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        
    }
    
    func start() {
        state = .tracking
        coordinates = [locationManager.location!.coordinate]
        
        locationManager.startUpdatingLocation()
        
        delegate?.didStart()
    }
    
    func resume() {
        state = .tracking
        locationManager.startUpdatingLocation()
        
        delegate?.didResume()
    }
    
    func pause() {
        state = .pause
        locationManager.stopUpdatingLocation()
        
        delegate?.didPause()
    }
    
    func stop() {
        state = .idle
        locationManager.stopUpdatingLocation()
        
        delegate?.didStop()
    }
    
}

extension RouteTracker: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard state == .tracking else { return }
        
        if let newCoordinate = locations.first?.coordinate {
            coordinates.append(newCoordinate)
        }
        
        delegate?.locationUpdate(coordinates)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
}

var tempCoordinates: [CLLocationCoordinate2D] = [
    .init(latitude: 56.253762, longitude: 40.551965),
    .init(latitude: 56.253016, longitude: 40.552228),
    .init(latitude: 56.253102, longitude: 40.553239),
    .init(latitude: 56.253768, longitude: 40.552955),
    .init(latitude: 56.253920, longitude: 40.553585),
    .init(latitude: 56.254207, longitude: 40.553678),
    .init(latitude: 56.254365, longitude: 40.553090),
    .init(latitude: 56.254046, longitude: 40.551197)
]
