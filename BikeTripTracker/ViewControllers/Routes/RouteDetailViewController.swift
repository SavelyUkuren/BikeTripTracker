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
    
	@IBOutlet weak var speedGraphPosView: UIView!
	@IBOutlet weak var noSpeedGraphDataLabel: UILabel!
	private var speedLineChartView: LineChart!
	
	@IBOutlet weak var elevateionGraphPosView: UIView!
	@IBOutlet weak var noElevationGraphDataLabel: UILabel!
	private var elevationLineChartView: LineChart!
	
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
		startLoadingGraphs()
    }
    
    private func startLoadingMap() {
        
        mapViewLoadIndicator.startAnimating()
        setupRouteMap() {
            DispatchQueue.main.async {
                self.addMapViewToScreen()
            }
        }
        
    }
	
	private func startLoadingGraphs() {
		
		configureSpeedLineChart() {
			DispatchQueue.main.async {
				self.noSpeedGraphDataLabel.isHidden = true
				self.addSpeedGraphToScreen()
			}
		}
		
		configureElevationLineChart() {
			DispatchQueue.main.async {
				self.noElevationGraphDataLabel.isHidden = true
				self.addElevationGraphToScreen()
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
	
	private func configureSpeedLineChart(complitionHandler: (() -> ())? = nil) {
		speedLineChartView = LineChart(frame: speedGraphPosView.frame)
		speedLineChartView.translatesAutoresizingMaskIntoConstraints = false
		
		speedLineChartView.animation.enabled = false
		speedLineChartView.dots.visible = false
		speedLineChartView.y.grid.count = 6
		speedLineChartView.x.grid.count = 5
		
		speedLineChartView.x.axis.inset = 30
		speedLineChartView.y.axis.inset = 30
		
		speedLineChartView.delegate = self
		
		DispatchQueue.global(qos: .userInitiated).async {
			guard let route = self.route else { return }
			guard route.locations.count > 2 else { return }
			
			var xLabels: [String] = []
			var speedData: [CGFloat] = []
			let distance = route.distance / (Settings.shared.distanceMeasureUnit == .kilometers ? 1000 : 1)
			let distanceStep = distance / CGFloat(self.speedLineChartView.x.grid.count)
			
			for index in 1...Int(self.speedLineChartView.x.grid.count) {
				let distance = String((CGFloat(index) * distanceStep).round(to: 2)) + " \(self.distanceMUStr)"
				xLabels.append(distance)
			}
			
			for (_, locationModel) in route.locations.enumerated() {
				let speed = (locationModel.speed ?? 0) * (Settings.shared.speedMeasureUnit == .kilometersPerHour ? 3.6 : 1)
				speedData.append(speed)
			}
			
			self.speedLineChartView.x.labels.values = xLabels
			
			DispatchQueue.main.async {
				speedData = self.applyMovingAverage(to: speedData, windowSize: speedData.count / 10)
				self.speedLineChartView.addLine(speedData)
				
			}
			
			if let complitionHandler = complitionHandler {
				complitionHandler()
			}
		}

	}
	
	private func configureElevationLineChart(complitionHandler: (() -> ())? = nil) {
		elevationLineChartView = LineChart(frame: speedGraphPosView.frame)
		elevationLineChartView.translatesAutoresizingMaskIntoConstraints = false
		
		elevationLineChartView.animation.enabled = false
		elevationLineChartView.dots.visible = false
		elevationLineChartView.y.grid.count = 6
		elevationLineChartView.x.grid.count = 5
		
		elevationLineChartView.x.axis.inset = 30
		elevationLineChartView.y.axis.inset = 30
		
		elevationLineChartView.colors[0] = .systemGreen
		elevationLineChartView.delegate = self
		
		DispatchQueue.global(qos: .userInitiated).async {
			guard let route = self.route else { return }
			guard route.locations.count > 2 else { return }
			
			var xLabels: [String] = []
			var altitudeData: [CGFloat] = []
			let distance = route.distance / (Settings.shared.distanceMeasureUnit == .kilometers ? 1000 : 1)
			let distanceStep = distance / CGFloat(self.elevationLineChartView.x.grid.count)
			
			for index in 1...Int(self.speedLineChartView.x.grid.count) {
				let distance = String((CGFloat(index) * distanceStep).round(to: 2)) + " \(self.distanceMUStr)"
				xLabels.append(distance)
			}
			
			for (_, locationModel) in route.locations.enumerated() {
				let altitude = (locationModel.altitude ?? 0) //* (Settings.shared.speedMeasureUnit == .kilometersPerHour ? 3.6 : 1)
				altitudeData.append(altitude)
			}
			
			self.elevationLineChartView.x.labels.values = xLabels
			
			DispatchQueue.main.async {
				altitudeData = self.applyMovingAverage(to: altitudeData, windowSize: altitudeData.count / 10)
				self.elevationLineChartView.addLine(altitudeData)
				
			}
			
			if let complitionHandler = complitionHandler {
				complitionHandler()
			}
		}
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
	
	private func addSpeedGraphToScreen() {
		speedGraphPosView.addSubview(speedLineChartView)
		NSLayoutConstraint.activate([
			self.speedLineChartView.topAnchor.constraint(equalTo: self.speedGraphPosView.topAnchor, constant: 0),
			self.speedLineChartView.leadingAnchor.constraint(equalTo: self.speedGraphPosView.leadingAnchor, constant: 0),
			self.speedLineChartView.trailingAnchor.constraint(equalTo: self.speedGraphPosView.trailingAnchor, constant: -0),
			self.speedLineChartView.heightAnchor.constraint(equalTo: self.speedGraphPosView.heightAnchor, constant: -0)
		])
	}
	
	private func addElevationGraphToScreen() {
		elevateionGraphPosView.addSubview(elevationLineChartView)
		NSLayoutConstraint.activate([
			self.elevationLineChartView.topAnchor.constraint(equalTo: self.elevateionGraphPosView.topAnchor, constant: 0),
			self.elevationLineChartView.leadingAnchor.constraint(equalTo: self.elevateionGraphPosView.leadingAnchor, constant: 0),
			self.elevationLineChartView.trailingAnchor.constraint(equalTo: self.elevateionGraphPosView.trailingAnchor, constant: -0),
			self.elevationLineChartView.heightAnchor.constraint(equalTo: self.elevateionGraphPosView.heightAnchor, constant: -0)
		])
	}
	
	private func applyMovingAverage(to data: [CGFloat], windowSize: Int) -> [CGFloat] {
		guard windowSize > 1 else { return data }
		
		var smoothedData: [CGFloat] = []
		
		for i in 0..<data.count {
			let start = max(0, i - windowSize / 2)
			let end = min(data.count - 1, i + windowSize / 2)
			let window = data[start...end]
			let average = window.reduce(0, +) / CGFloat(window.count)
			
			smoothedData.append(average)
		}
		
		return smoothedData
	}
	
	private func addAnnotation(locationModel: LocationModel) {
		let annotation = MKPointAnnotation()
		annotation.coordinate = CLLocationCoordinate2D(latitude: locationModel.latitude, longitude: locationModel.longitude)
		
		mapView?.addAnnotation(annotation)
		
	}
	
	private func centerMap(locationModel: LocationModel) {
		let regionRadius: CLLocationDistance = 100
		let coordinate = CLLocationCoordinate2D(latitude: locationModel.latitude, longitude: locationModel.longitude)
		let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
		mapView?.setRegion(coordinateRegion, animated: false)
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

extension RouteDetailViewController: LineChartDelegate {
	func didSelectDataPoint(_ x: CGFloat, yValues: [CGFloat]) {

		guard let route = route else { return }
		guard route.locations.indices.contains(Int(x)) else { return }
		let location = route.locations[Int(x)]
		
		mapView?.annotations.forEach({
			mapView?.removeAnnotation($0)
		})
		
		addAnnotation(locationModel: location)
		centerMap(locationModel: location)
		
	}
}
