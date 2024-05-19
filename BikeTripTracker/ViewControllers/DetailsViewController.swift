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
    private var updateTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewCornerRadius()
        currentSpeedLabel.text = "0"
        
        let masureUnitStr = routeTracker.speedMeasureUnit == .metersPerSecond ? "m/s" : "km/h"
//        currenctSpeedTitleLabel.text = "Speed (\(masureUnitStr))"
        
        updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
        updateTimer.fire()
        
    }
    
    @objc private func updateInfo() {
        guard routeTracker.state == .tracking else { return }
        
        currentSpeedLabel.text = String(routeTracker.speed.round(to: 1))
        distanceLabel.text = String(routeTracker.distance.round(to: 2))
        
        let time = convertSecondsToHMS(RouteTracker.shared.timeDuration)
        timeLabel.text = time
        
        let maxSpeed = routeTracker.maxSpeed.round(to: 1)
        let avgSpeed = routeTracker.avgSpeed.round(to: 1)
        
        maxSpeedLabel.text = String(maxSpeed)
        avgSpeedLabel.text = String(avgSpeed)
        
    }
    
    private func configureViewCornerRadius() {
        view.layer.cornerRadius = 25
        
        dragView.layer.cornerRadius = 25
        dragView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
    }
    
    /// Converting seconds to Hour:Minute:Sec
    private func convertSecondsToHMS(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        
        let formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return formattedTime
    }
    
    // MARK: - Actions
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
}
