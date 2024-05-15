//
//  ViewController.swift
//  BikeTripTracker
//
//  Created by savik on 14.05.2024.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    private var tempCoordinates: [CLLocationCoordinate2D] = [
        .init(latitude: 56.253762, longitude: 40.551965),
        .init(latitude: 56.253016, longitude: 40.552228),
        .init(latitude: 56.253102, longitude: 40.553239),
        .init(latitude: 56.253768, longitude: 40.552955),
        .init(latitude: 56.253920, longitude: 40.553585),
        .init(latitude: 56.254207, longitude: 40.553678),
        .init(latitude: 56.254365, longitude: 40.553090),
        .init(latitude: 56.254046, longitude: 40.551197)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.delegate = self
        mapView.delegate = self
        
        mapView.setCenter(tempCoordinates[0], animated: true)
        mapView.setRegion(MKCoordinateRegion(center: tempCoordinates[0], latitudinalMeters: 300, longitudinalMeters: 300), animated: true)
        
        let polyline = MKPolyline(coordinates: tempCoordinates, count: tempCoordinates.count)
        mapView.addOverlay(polyline)

    }

}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        tempCoordinates.append(locations.first!.coordinate)
        
        if let oldOverlay = mapView.overlays.first {
            mapView.removeOverlay(oldOverlay)
        }
        
        let polyline = MKPolyline(coordinates: tempCoordinates, count: tempCoordinates.count)
        mapView.addOverlay(polyline)
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

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        
        render.strokeColor = .systemBlue
        render.lineWidth = 5
        
        return render
    }
    
}

