//
//  RouteModel.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//

import Foundation

struct RouteModel {
    var id: UUID
    var date: Date
    var travelTime: Int
    var distance: Double
    var maxSpeed: Double
    var avgSpeed: Double
    var locations: [LocationModel]
}
