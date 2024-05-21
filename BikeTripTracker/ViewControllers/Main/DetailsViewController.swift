//
//  DetailViewController.swift
//  BikeTripTracker
//
//  Created by savik on 15.05.2024.
//

import UIKit
import OverlayContainer

class DetailsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dragView: UIView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var currenctSpeedTitleLabel: UILabel!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceTitleLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var travelTimeTitleLabel: UILabel!
    
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    
    private var routeTracker = RouteTracker.shared
    private var settings = Settings.shared
    private var updateTimer: Timer!
    
    private var speedMeasureUnitText = ""
    private var distanceMeasureUnit = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewCornerRadius()
        configureLabels()
        configureTimer()
        
        configureNotificationCenter()
        
    }
    
    private func configureViewCornerRadius() {
        view.layer.cornerRadius = 25
        
        dragView.layer.cornerRadius = 25
        dragView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
    }
    
    private func configureLabels() {
        speedMeasureUnitText = settings.speedMeasureUnit == .metersPerSecond ? "m/s" : "km/h"
        distanceMeasureUnit = settings.distanceMeasureUnit == .meters ? "m" : "km"
        
        currentSpeedLabel.text = "0 \(speedMeasureUnitText)"
        distanceLabel.text = "0 \(distanceMeasureUnit)"
        maxSpeedLabel.text = "0 \(speedMeasureUnitText)"
        avgSpeedLabel.text = "0 \(speedMeasureUnitText)"
    }
    
    private func configureTimer() {
        updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
        updateTimer.fire()
    }
    
    private func configureNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidUpdate), name: NSNotification.Name("SettingsDidUpdate"), object: nil)
    }
    
    private func presentInfo() {
        speedMeasureUnitText = settings.speedMeasureUnit == .metersPerSecond ? "m/s" : "km/h"
        distanceMeasureUnit = settings.distanceMeasureUnit == .meters ? "m" : "km"
        
        // if speed measure unit will be km/s then convert m/s to km/s by multiply on 3.6
        let speed = settings.speedMeasureUnit == .metersPerSecond ? routeTracker.speed : routeTracker.speed * 3.6
        let avgSpeed = settings.speedMeasureUnit == .metersPerSecond ? routeTracker.avgSpeed : routeTracker.avgSpeed * 3.6
        let maxSpeed = settings.speedMeasureUnit == .metersPerSecond ? routeTracker.maxSpeed : routeTracker.maxSpeed * 3.6
        
        let distance = settings.distanceMeasureUnit == .meters ? routeTracker.distance : routeTracker.distance / 1000
        
        currentSpeedLabel.text = String(speed.round(to: 1)) + " " + speedMeasureUnitText
        distanceLabel.text = String(distance.round(to: 2)) + " " + distanceMeasureUnit
        
        let time = formatTime(seconds: RouteTracker.shared.timeDuration)
        timeLabel.text = time
        
        maxSpeedLabel.text = String(maxSpeed.round(to: 1)) + " " + speedMeasureUnitText
        avgSpeedLabel.text = String(avgSpeed.round(to: 1)) + " " + speedMeasureUnitText
    }
    
    // MARK: - Actions
    @objc private func updateInfo() {
        guard routeTracker.state == .tracking else { return }
        presentInfo()
    }
    
    @objc private func settingsDidUpdate() {
        presentInfo()
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        switch routeTracker.state {
        case .idle:
            routeTracker.start()
        case .tracking:
            routeTracker.pause()
        case .pause:
            routeTracker.resume()
        }
        
        let changeStartButtonIcon = routeTracker.state == .idle || routeTracker.state == .pause
        startButton.setImage(UIImage(systemName: changeStartButtonIcon ? "play.fill" : "pause.fill"), for: .normal)
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        routeTracker.stop()
        startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    @IBAction func routesButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let routesNC = storyboard.instantiateViewController(withIdentifier: "routesNC")
        present(routesNC, animated: true)
        
    }
    
}
