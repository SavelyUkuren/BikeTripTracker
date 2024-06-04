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
    private var detailsVC: DetailsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeTracker.delegate = self

        mapView.delegate = self
        
        if let userCoordinate = routeTracker.locationManager.location?.coordinate {
            mapView.setCenter(userCoordinate, animated: true)
            mapView.setRegion(MKCoordinateRegion(center: userCoordinate, latitudinalMeters: 100, longitudinalMeters: 100), animated: true)
        }
        
    }
    
    func showErrorMessage(msg: String) {
        let alert = UIAlertController(title: "Error",
                                      message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
}

extension MapViewController: RouteTrackerDelegate {
    
    func locationUpdate(_ locations: [LocationModel]) {
        
        if locations.count > 2 {
            let c = locations.count - 1
            
            let start = CLLocationCoordinate2D(latitude: locations[c - 1].latitude, longitude: locations[c - 1].longitude)
            let end = CLLocationCoordinate2D(latitude: locations[c].latitude, longitude: locations[c].longitude)
            
            var color = UIColor.systemGreen
            if let speed = locations[c].speed {
                color = colorBySpeed(speed)
            }
            
            let coords = [start, end]
            let polyline = RoutePolyline(coordinates: coords, count: coords.count)
            polyline.color = color
            mapView.addOverlay(polyline)
        }
        
    }
    
    func errorOccured(msg: String) {
        showErrorMessage(msg: msg)
    }
    
    func didStart() {
        
    }
    
    func didStop() {
        mapView.overlays.forEach {
            mapView.removeOverlay($0)
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        guard let routeOverlay = overlay as? RoutePolyline else {
            return MKPolygonRenderer(overlay: overlay)
        }
        
        let render = MKPolylineRenderer(overlay: overlay)
        
        render.strokeColor = routeOverlay.color
        render.lineWidth = 5
        
        return render
    }
    
}

