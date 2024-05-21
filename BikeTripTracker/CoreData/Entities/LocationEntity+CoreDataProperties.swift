//
//  LocationEntity+CoreDataProperties.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//
//

import Foundation
import CoreData


extension LocationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationEntity> {
        return NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var speed: Double
    @NSManaged public var index: Int64
    @NSManaged public var route: RouteEntity?

}

extension LocationEntity : Identifiable {

}
