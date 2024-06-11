//
//  MainViewController.swift
//  BikeTripTracker
//
//  Created by savik on 15.05.2024.
//

import UIKit
import OverlayContainer

class MainViewController: UIViewController {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Actions
    @IBAction func playPauseButtonTapped(_ sender: Any) {
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
    }
    
}
