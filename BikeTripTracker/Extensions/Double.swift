//
//  Double.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//

import Foundation

extension Double {
    /*
     Example
     Input:
        places: 2
        self: 2.423536
     Output:
        2.42
     
     */
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
