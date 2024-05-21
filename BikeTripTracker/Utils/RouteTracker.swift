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
    
    var speed: CLLocationSpeed {
        guard let speed = locationManager.location?.speed else { return 0 }
        guard speed > 0 else { return 0 }
        if speed > maxSpeed { maxSpeed = speed }
        return speed
    }
    var avgSpeed: Double {
        return distance / Double(timeDuration)
    }
    var maxSpeed: CLLocationSpeed = 0
    var distance: Double = 0
    var timeDuration: Int = 0
    
    weak var delegate: RouteTrackerDelegate?
    
    private(set) var state: TrackerState = .idle
    private(set) var locationManager = CLLocationManager()
    private(set) var locations: [LocationModel] = []
    
    private var startTime: Date? = nil
    private var timer: Timer?
    private var timerIsRunning = false
    
    private let coreDataManager = CoreDataManager()
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
    }
    
    func start() {
        state = .tracking
        distance = 0
        timeDuration = 0
        
        let startCoordinate = locationManager.location!.coordinate
        locations = [LocationModel(latitude: startCoordinate.latitude,
                                   longtitude: startCoordinate.longitude)]
        
        startTime = Date()
        
        if !timerIsRunning {
            timerIsRunning = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeDuration), userInfo: nil, repeats: true)
            timer?.fire()
        }
        
        locationManager.startUpdatingLocation()
        
        delegate?.didStart()
    }
    
    func resume() {
        state = .tracking
        locationManager.startUpdatingLocation()
        
        timerIsRunning = true
        startTime = Date().addingTimeInterval(-Double(timeDuration))
        
        delegate?.didResume()
    }
    
    func pause() {
        state = .pause
        locationManager.stopUpdatingLocation()
        
        timerIsRunning = false
        
        delegate?.didPause()
    }
    
    func stop() {
        state = .idle
        locationManager.stopUpdatingLocation()
        
        timerIsRunning = false
        timer?.invalidate()
        timer = nil
        
        delegate?.didStop()
        
        saveRoute()
    }
    
    private func calculateDistance() {
        let count = locations.count
        guard count > 1 else { return }
        
        let l1 = CLLocation(latitude: locations[count - 2].latitude, longitude: locations[count - 2].longitude)
        let l2 = CLLocation(latitude: locations[count - 1].latitude, longitude: locations[count - 1].longitude)
        
        distance += l2.distance(from: l1)
    }
    
    private func saveRoute() {
        let route = RouteModel(id: UUID(), date: Date(),
                               travelTime: timeDuration,
                               distance: distance,
                               maxSpeed: maxSpeed,
                               avgSpeed: avgSpeed, locations: locations)
        
        coreDataManager.saveRoute(route)
    }
    
    @objc private func updateTimeDuration() {
        guard timerIsRunning else { return }
        guard let startTime = startTime else { return }
        
        timeDuration = Int(Date().timeIntervalSince(startTime))
    }
    
}

extension RouteTracker: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard state == .tracking else { return }
        
        if let newCoordinate = locations.first?.coordinate {
            let locModel = LocationModel(latitude: newCoordinate.latitude,
                                         longtitude: newCoordinate.longitude, speed: speed)
            self.locations.append(locModel)
        }
        
        calculateDistance()
        
        delegate?.locationUpdate(self.locations)
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

// temp data for debug. Can delete
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

var tempLocations: [LocationModel] = tempCoordinates.map {
    LocationModel(latitude: $0.latitude, longtitude: $0.longitude, speed: Double.random(in: 0...60))
}
