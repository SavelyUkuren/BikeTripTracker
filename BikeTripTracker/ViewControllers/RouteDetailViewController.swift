//
//  RouteDetailViewController.swift
//  BikeTripTracker
//
//  Created by savik on 20.05.2024.
//

import UIKit
import MapKit

class RouteDetailViewController: UIViewController {

    var route: RouteModel?
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRouteInfo()
        setupRouteMap()
        
    }

    private func setupRouteInfo() {
        guard let route = route else {
            print ("'route' is nil")
            return
        }
        
        distanceLabel.text = String(route.distance.round(to: 2)) + " km"
        averageSpeedLabel.text = String(route.avgSpeed.round(to: 1)) + " km/h"
        timeLabel.text = formatTime(seconds: route.travelTime)
        maxSpeedLabel.text = String(route.maxSpeed.round(to: 1)) + " km/h"
        
    }
    
    private func setupRouteMap() {
        guard let locations = route?.locations, !locations.isEmpty else {
            return
        }
        
        mapView.delegate = self
        
        let coord = CLLocationCoordinate2D(latitude: locations[0].latitude, longitude: locations[0].longitude)
        mapView.setCenter(coord, animated: true)
        mapView.setRegion(MKCoordinateRegion(center: coord, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
        
        for index in 0..<locations.count - 1 {
            let start = CLLocationCoordinate2D(latitude: locations[index].latitude, longitude: locations[index].longitude)
            let end = CLLocationCoordinate2D(latitude: locations[index + 1].latitude, longitude: locations[index + 1].longitude)
            
            var color = UIColor.systemGreen
            if let speed = locations[index].speed {
                color = colorBySpeed(speed)
            }
            
            let coords = [start, end]
            let polyline = RoutePolyline(coordinates: coords, count: coords.count)
            polyline.color = color
            mapView.addOverlay(polyline)
        }
    }
    
    private func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m \(remainingSeconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
        }
    }
}

extension RouteDetailViewController: MKMapViewDelegate {
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