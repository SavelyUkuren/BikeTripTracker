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
    
    
    @IBOutlet weak var mapViewLoadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapViewPlacement: UIView!
    private var mapView: MKMapView?
    
    private var settings = Settings.shared
    private var coordinates: [RoutePolyline] = []
    
    private var startRenderTime = Date()
	
	private var speedMUStr: String { NSLocalizedString(Settings.shared.speedMeasureUnit.rawValue, comment: "") }
	private var distanceMUStr: String = NSLocalizedString(Settings.shared.distanceMeasureUnit.rawValue, comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureMapView()
        startLoadingMap()
        setupRouteInfo()
        
    }
    
    private func startLoadingMap() {
        
        mapViewLoadIndicator.startAnimating()
        setupRouteMap() {
            DispatchQueue.main.async {
                self.addMapViewToScreen()
            }
        }
        
    }

    private func setupRouteInfo() {
        guard let route = route else {
            print ("'route' is nil")
            return
        }
        
        let avgSpeed = settings.speedMeasureUnit == .metersPerSecond ? route.avgSpeed : route.avgSpeed * 3.6
        let maxSpeed = settings.speedMeasureUnit == .metersPerSecond ? route.maxSpeed : route.maxSpeed * 3.6
        
        let distance = settings.distanceMeasureUnit == .meters ? route.distance : route.distance / 1000
        
        distanceLabel.text = String(distance.round(to: 2)) + " " + distanceMUStr
        averageSpeedLabel.text = String(avgSpeed.round(to: 1)) + " " + speedMUStr
        timeLabel.text = formatTime(seconds: route.travelTime)
        maxSpeedLabel.text = String(maxSpeed.round(to: 1)) + " " + speedMUStr
        
    }
    
    private func setupRouteMap(complitionHandler: (() -> ())? = nil) {
        guard let locations = route?.locations, !locations.isEmpty else {
            return
        }
        
        mapView?.delegate = self
        
        let coord = CLLocationCoordinate2D(latitude: locations[0].latitude, longitude: locations[0].longitude)
        mapView?.setCenter(coord, animated: true)
        mapView?.setRegion(MKCoordinateRegion(center: coord, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
        
        DispatchQueue.global(qos: .userInitiated).async {
            
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
                
                if routeFilter(lastCoord: start, newCoord: end) {
                    self.mapView?.addOverlay(polyline)
                }
            }
            
            if let complitionHandler = complitionHandler {
                complitionHandler()
            }
        }
        
    }
    
    private func configureMapView() {
        mapView = MKMapView(frame: mapViewPlacement.frame)
        mapView?.translatesAutoresizingMaskIntoConstraints = false
        mapView?.layer.cornerRadius = 20
    }
    
    private func addMapViewToScreen() {
        mapViewPlacement?.addSubview(mapView!)
        
        NSLayoutConstraint.activate([
            mapView!.topAnchor.constraint(equalTo: mapViewPlacement.topAnchor),
            mapView!.leadingAnchor.constraint(equalTo: mapViewPlacement.leadingAnchor),
            mapView!.bottomAnchor.constraint(equalTo: mapViewPlacement.bottomAnchor),
            mapView!.trailingAnchor.constraint(equalTo: mapViewPlacement.trailingAnchor),
        ])
        
        mapViewLoadIndicator.stopAnimating()
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
