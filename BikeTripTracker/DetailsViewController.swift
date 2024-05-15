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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewCornerRadius()
        
    }
    
    private func configureViewCornerRadius() {
        view.layer.cornerRadius = 25
        dragView.layer.cornerRadius = 25
        dragView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        scrollView.layer.cornerRadius = 25
    }

}
