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
    
    private var routeTracker = RouteTracker.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewCornerRadius()
        
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
