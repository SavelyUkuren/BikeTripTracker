//
//  LocationModel.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//

import Foundation

struct LocationModel {
    var latitude: Double
    var longitude: Double
    var speed: Double?
    var index: Int?
    
    init(latitude: Double, longtitude: Double, speed: Double? = nil, index: Int? = nil) {
        self.latitude = latitude
        self.longitude = longtitude
        self.speed = speed
        self.index = index
        
    }
}
