//
//  HelpfulFunctions.swift
//  BikeTripTracker
//
//  Created by savik on 20.05.2024.
//

import Foundation
import UIKit

func colorBySpeed(_ speed: Double) -> UIColor {
    var color = UIColor.systemGreen
    // km/h
    if speed > 0 && speed < 10 {
        color = .systemBlue
    } else if speed > 10 && speed < 30 {
        color = .systemGreen
    } else if speed > 30 && speed < 45 {
        color = .systemOrange
    } else {
        color = .systemRed
    }
    
    return color
}
