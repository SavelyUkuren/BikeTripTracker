//
//  MainViewController.swift
//  BikeTripTracker
//
//  Created by savik on 15.05.2024.
//

import UIKit
import OverlayContainer

class MainViewController: OverlayContainerViewController {
    
    enum OverlaySize: Int, CaseIterable {
        case min
        case medium
        case max
    }

    var detailsVC: DetailsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewControllers()
        
        self.delegate = self
    }
    
    private func configureViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MapVC") as! MapViewController
        detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsVC") as? DetailsViewController
        
        self.viewControllers = [mapVC, detailsVC!]
    }
    
}

extension MainViewController: OverlayContainerViewControllerDelegate {
    func overlayContainerViewController(_ containerViewController: OverlayContainer.OverlayContainerViewController, heightForNotchAt index: Int, availableSpace: CGFloat) -> CGFloat {
        switch OverlaySize.allCases[index] {
        case .min:
            return availableSpace * 1 / 6
        case .medium:
            return availableSpace / 2
        case .max:
            return availableSpace * 5 / 6
        }
    }
    
    func numberOfNotches(in containerViewController: OverlayContainer.OverlayContainerViewController) -> Int {
        OverlaySize.allCases.count
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController, scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
        detailsVC!.scrollView
    }
}
