//
//  RouteEntity+CoreDataProperties.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//
//

import Foundation
import CoreData


extension RouteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RouteEntity> {
        return NSFetchRequest<RouteEntity>(entityName: "RouteEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var travelTime: Int64
    @NSManaged public var distance: Double
    @NSManaged public var avgSpeed: Double
    @NSManaged public var maxSpeed: Double
    @NSManaged public var locations: NSSet?

}

// MARK: Generated accessors for locations
extension RouteEntity {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: LocationEntity)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: LocationEntity)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

extension RouteEntity : Identifiable {

}
