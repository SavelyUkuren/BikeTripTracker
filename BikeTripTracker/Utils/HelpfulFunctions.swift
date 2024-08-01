//
//  HelpfulFunctions.swift
//  BikeTripTracker
//
//  Created by savik on 20.05.2024.
//

import Foundation
import UIKit
import CoreLocation

let maxDistance: CLLocationDistance = 40.0 //Threshold to prevent sudden changes in location (m/s)

func colorBySpeed(_ speed: Double) -> UIColor {
    var color = UIColor.systemBlue
	// Rework in the future
    // km/h
//    if speed > 0 && speed < kilometerPerHour(10) {
//        color = .systemBlue
//    } else if speed > kilometerPerHour(15) && speed < kilometerPerHour(25) {
//        color = .systemGreen
//    } else if speed > kilometerPerHour(25) && speed < kilometerPerHour(35) {
//        color = .systemOrange
//    } else {
//        color = .systemRed
//    }
    
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

	let hS = NSLocalizedString("t_h", comment: "Hours")
	let mS = NSLocalizedString("t_m", comment: "Minutes")
	let sS = NSLocalizedString("t_s", comment: "Seconds")
	
	var output = ""

	if hours > 0 {
		output += "\(hours)\(hS) "
	}
	if minutes > 0 {
		output += "\(minutes)\(mS) "
	}
	
	output += "\(remainingSeconds)\(sS)"
	
	return output
}

func routeFilter(lastCoord: CLLocationCoordinate2D, newCoord: CLLocationCoordinate2D) -> Bool {
    let lastLocation = CLLocation(latitude: lastCoord.latitude, longitude: lastCoord.longitude)
    let newLocation = CLLocation(latitude: newCoord.latitude, longitude: newCoord.longitude)
    
    let distance = lastLocation.distance(from: newLocation)
    
    if distance > maxDistance {
        return false
    }
    
    return true
}

func kilometerPerHour(_ meterPerSec: Double) -> Double {
    return meterPerSec / 3.6
}
