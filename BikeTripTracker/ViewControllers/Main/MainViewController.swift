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
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    private var routeTracker = RouteTracker()
    private var settings = Settings.shared
    private var updateTimer: Timer!
	
	private var speedMUStr: String { NSLocalizedString(Settings.shared.speedMeasureUnit.rawValue, comment: "") }
	private var distanceMUStr: String = NSLocalizedString(Settings.shared.distanceMeasureUnit.rawValue, comment: "")
    
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
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        let status = routeTracker.locationManager.authorizationStatus
        guard status != .denied, status != .restricted else {
            showErrorMessage(msg: NSLocalizedString("Allow access to your location.", comment: ""))
            return
        }
        
        isLocationTracking.toggle()
        
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        
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
			DispatchQueue.main.async {
				self.mapView.updateFocusIfNeeded()
			}
        }
    }
    
    private func setup() {
        routeTracker.delegate = self
		mapView.userTrackingMode = .follow
        
        setupMapView()
        setupMenu()
        setupFonts()
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
    
    private func setupFonts() {
        speedLabel.font = .rounded(ofSize: speedLabel.font.pointSize, weight: .bold)
        distanceLabel.font = .rounded(ofSize: distanceLabel.font.pointSize, weight: .bold)
        timeLabel.font = .rounded(ofSize: timeLabel.font.pointSize, weight: .bold)
    }
    
    private func setupMenu() {
        var actions: [UIAction] = []
        actions.append(UIAction(title: NSLocalizedString("Settings", comment: ""), image: UIImage(systemName: "gearshape.fill"), handler: { _ in self.openSettings() }))
        actions.append(UIAction(title: NSLocalizedString("Routes", comment: ""), image: UIImage(systemName: "list.bullet"), handler: { _ in self.openRoutes() }))
        
        let menu = UIMenu(children: actions)
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true
    }
    
    private func showErrorMessage(msg: String) {
		let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)

        present(alert, animated: true)
    }
    
    private func showAlertIfStopButtonTapped(yesAction: @escaping (UIAlertAction) -> ()) {
        let alert = UIAlertController(title: NSLocalizedString("Stop tracking", comment: ""),
                                      message: NSLocalizedString("Do you really want to finish the route?", comment: ""),
									  preferredStyle: .alert)

        let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: yesAction)

        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default)

        alert.addAction(noAction)
        alert.addAction(yesAction)

        present(alert, animated: true)
    }
    
    private func presentInfo() {

        // if speed measure unit will be km/s then convert m/s to km/s by multiply on 3.6
        let speed = settings.speedMeasureUnit == .metersPerSecond ? routeTracker.speed : routeTracker.speed * 3.6

        let distance = settings.distanceMeasureUnit == .meters ? routeTracker.distance : routeTracker.distance / 1000
		
        speedLabel.text = String(speed.round(to: 1)) + " " + speedMUStr
        distanceLabel.text = String(distance.round(to: 2)) + " " + distanceMUStr

        let time = formatTime(seconds: routeTracker.timeDuration)
        timeLabel.text = time
    }
    
    private func openSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsNC = storyboard.instantiateViewController(identifier: "SettingsNC")
		settingsNC.sheetPresentationController?.detents = [.medium()]
        present(settingsNC, animated: true)
    }
    
    private func openRoutes() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let routesNC = storyboard.instantiateViewController(identifier: "RoutesNC")
        present(routesNC, animated: true)
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
		DispatchQueue.global().async {
			self.mapView.overlays.forEach {
				self.mapView.removeOverlay($0)
			}
		}
        
        speedLabel.text = "0 " + speedMUStr
        distanceLabel.text = "0 " + distanceMUStr
        timeLabel.text = formatTime(seconds: 0)//"0" + secondsMUStr
		
		playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
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
