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

/*
 Examples:
    Input: 32
    Output: 32s
 
    Input: 155
    Output: 2m 25s
 
    Input: 3600
    Output: 1h 0m 0s
    
 */
func formatTime(seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let remainingSeconds = seconds % 60

    if hours > 0 {
        return "\(hours)h \(minutes)m \(remainingSeconds)s"
    } else if minutes > 0 {
        return "\(minutes)m \(remainingSeconds)s"
    } else {
        return "\(remainingSeconds)s"
    }
}

