//
//  MainViewController.swift
//  BikeTripTracker
//
//  Created by savik on 15.05.2024.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    private var routeTracker = RouteTracker()
    private var settings = Settings.shared
    private var updateTimer: Timer!
    
    private var speedMeasureUnitText: String {
        return Settings.shared.speedMeasureUnit == .metersPerSecond ? "m/s" : "km/h"
    }
    private var distanceMeasureUnit: String {
        return Settings.shared.distanceMeasureUnit == .meters ? "m" : "km"
    }
    
    private var isLocationTracking = false {
        didSet {
            locationButton.setImage(UIImage(systemName: isLocationTracking ? "location.fill" : "location"), for: .normal)
            mapView.userTrackingMode = isLocationTracking ? .follow : .none
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Actions
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        switch routeTracker.state {
        case .idle:
            routeTracker.start()
        case .tracking:
            routeTracker.pause()
        case .pause:
            routeTracker.resume()
        }

        let changeStartButtonIcon = routeTracker.state == .idle || routeTracker.state == .pause
        playPauseButton.setImage(UIImage(systemName: changeStartButtonIcon ? "play.fill" : "pause.fill"), for: .normal)
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        showAlertIfStopButtonTapped { _ in
            self.routeTracker.stop()
            self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        
        isLocationTracking.toggle()
        
    }
    
    @objc private func updateInfo() {
        guard routeTracker.state == .tracking else { return }
        presentInfo()
    }
    
    // Action When a user pan the map
    @objc private func mapDidPanning(
        _ gestureRecognizer: UIPanGestureRecognizer
    ) {
        if gestureRecognizer.state == .changed {
            isLocationTracking = false
        }
        if gestureRecognizer.state == .ended {
            mapView.updateFocusIfNeeded()
        }
    }
    
    private func setup() {
        routeTracker.delegate = self
        
        setupMapView()
        setupTimer()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(mapDidPanning(_:))
        )
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
    }
    
    private func setupTimer() {
        updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
        updateTimer.fire()
    }
    
    private func showErrorMessage(msg: String) {
        let alert = UIAlertController(title: "Error",
                                      message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)

        present(alert, animated: true)
    }
    
    private func showAlertIfStopButtonTapped(yesAction: @escaping (UIAlertAction) -> ()) {
        let alert = UIAlertController(title: "Stop tracking",
                                      message: "Do you really want to finish the route?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: yesAction)

        let noAction = UIAlertAction(title: "No", style: .default)

        alert.addAction(noAction)
        alert.addAction(yesAction)

        present(alert, animated: true)
    }
    
    private func presentInfo() {

        // if speed measure unit will be km/s then convert m/s to km/s by multiply on 3.6
        let speed = settings.speedMeasureUnit == .metersPerSecond ? routeTracker.speed : routeTracker.speed * 3.6
//        let avgSpeed = settings.speedMeasureUnit == .metersPerSecond ? routeTracker.avgSpeed : routeTracker.avgSpeed * 3.6
//        let maxSpeed = settings.speedMeasureUnit == .metersPerSecond ? routeTracker.maxSpeed : routeTracker.maxSpeed * 3.6

        let distance = settings.distanceMeasureUnit == .meters ? routeTracker.distance : routeTracker.distance / 1000

        speedLabel.text = String(speed.round(to: 1)) + " " + speedMeasureUnitText
        distanceLabel.text = String(distance.round(to: 2)) + " " + distanceMeasureUnit

        let time = formatTime(seconds: routeTracker.timeDuration)
        timeLabel.text = time

//        maxSpeedLabel.text = String(maxSpeed.round(to: 1)) + " " + speedMeasureUnitText
//        avgSpeedLabel.text = String(avgSpeed.round(to: 1)) + " " + speedMeasureUnitText
    }
    
}

// MARK: - Route tracker delegate
extension MainViewController: RouteTrackerDelegate {
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
        speedLabel.text = "0 " + speedMeasureUnitText
        distanceLabel.text = "0 " + distanceMeasureUnit
        timeLabel.text = "0s"
    }

}

// MARK: - MapKit render
extension MainViewController: MKMapViewDelegate {
    
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

// MARK: - Gesture recognizer delegate
extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
