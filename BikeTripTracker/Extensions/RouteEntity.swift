//
//  RouteEntity.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//

import Foundation

extension RouteEntity {
    var model: RouteModel {
        let id = self.id ?? UUID()
        let time = Int(self.travelTime)
        let distance = self.distance
        let maxSpeed = self.maxSpeed
        let avgSpeed = self.avgSpeed
        let date = self.date ?? Date()
        
        let locEntities = self.locations?.allObjects as! [LocationEntity]
        let locations: [LocationModel] = locEntities.map { $0.model }
        
        let m = RouteModel(id: id,
                           date: date,
                           travelTime: time,
                           distance: distance,
                           maxSpeed: maxSpeed,
                           avgSpeed: avgSpeed, locations: locations)
        return m
    }
}
