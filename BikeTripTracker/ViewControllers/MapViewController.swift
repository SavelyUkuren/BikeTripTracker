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
    
    private var routeTracker = RouteTracker.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeTracker.delegate = self

        mapView.delegate = self
        
        if let userCoordinate = routeTracker.locationManager.location?.coordinate {
            mapView.setCenter(userCoordinate, animated: true)
            mapView.setRegion(MKCoordinateRegion(center: userCoordinate, latitudinalMeters: 400, longitudinalMeters: 400), animated: true)
        }
        
    }

}

extension MapViewController: RouteTrackerDelegate {
    
    func locationUpdate(_ coordinates: [CLLocationCoordinate2D]) {
        if let oldOverlay = mapView.overlays.first {
            mapView.removeOverlay(oldOverlay)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
    }
    
    func didStart() {
        if let oldOverlay = mapView.overlays.first {
            mapView.removeOverlay(oldOverlay)
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

