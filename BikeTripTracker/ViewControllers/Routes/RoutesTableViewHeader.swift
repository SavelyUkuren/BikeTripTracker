//
//  RoutesTableViewHeader.swift
//  BikeTripTracker
//
//  Created by Савелий Никулин on 29.06.2024.
//

import UIKit

class RoutesTableViewHeader: UIView {

    var route: RoutesRow? {
        didSet {
            loadRoute()
        }
    }
    
    var titleLabel = UILabel()
    var totalDistanceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setupTitleLabel()
        setupDistanceLabel()
    }
    
    private func setupTitleLabel() {
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Title"
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func setupDistanceLabel() {
        totalDistanceLabel.textColor = .secondaryLabel
        totalDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        totalDistanceLabel.textAlignment = .right
        totalDistanceLabel.text = "Distance"
        
        addSubview(totalDistanceLabel)
        
        NSLayoutConstraint.activate([
            totalDistanceLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            totalDistanceLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func loadRoute() {
        guard let route = route else { return }
        
        titleLabel.text = route.title
        
        let distance = Settings.shared.distanceMeasureUnit == .kilometers ? route.totalDistance / 1000 : route.totalDistance
        totalDistanceLabel.text = String(distance.round(to: 2)) + " \(Settings.shared.distanceMeasureUnit.rawValue)"
    }
}
