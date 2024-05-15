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
    
    private var routeTracker = RouteTracker.shared
    private var updateTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewCornerRadius()
        currentSpeedLabel.text = "0"
        
        let masureUnitStr = routeTracker.speedMeasureUnit == .metersPerSecond ? "m/s" : "km/h"
        currenctSpeedTitleLabel.text = "Speed (\(masureUnitStr))"
        
        updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
        updateTimer.fire()
        
    }
    
    @objc private func updateInfo() {
        guard routeTracker.state == .tracking else { return }
        
        let speedText = Double(round(routeTracker.speed * 10) / 10)
        currentSpeedLabel.text = String(speedText)
    }
    
    private func configureViewCornerRadius() {
        view.layer.cornerRadius = 25
        
        dragView.layer.cornerRadius = 25
        dragView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
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
