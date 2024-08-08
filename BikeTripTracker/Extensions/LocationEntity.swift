//
//  LocationEntity.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//

import Foundation

extension LocationEntity {
    
    var model: LocationModel {
        let m = LocationModel(latitude: self.latitude,
                              longtitude: self.longitude,
							  speed: self.speed, altitude: self.altitude, index: Int(self.index))
        return m
    }
    
}
