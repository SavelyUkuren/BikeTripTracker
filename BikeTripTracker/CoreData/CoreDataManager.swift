//
//  CoreDataManager.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//

import UIKit
import CoreData

class CoreDataManager {
    
    private var viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func saveRoute(_ route: RouteModel) {
        guard let context = viewContext else {
            print ("CoreDataManager viewContext is nil")
            return
        }
        
        let rEntity = RouteEntity(context: context)
        rEntity.id = route.id
        rEntity.avgSpeed = route.avgSpeed
        rEntity.distance = route.distance
        rEntity.maxSpeed = route.maxSpeed
        rEntity.travelTime = Int64(route.travelTime)
        rEntity.date = route.date
        
        if !route.locations.isEmpty {
            for (index, location) in route.locations.enumerated() {
                let lEntity = LocationEntity(context: context)
                lEntity.latitude = location.latitude
                lEntity.longitude = location.longitude
                lEntity.speed = location.speed ?? 0
                lEntity.index = Int64(index)
                
                rEntity.addToLocations(lEntity)
            }
        }
        
        save()
    }
    
    func loadRoutes() -> [RouteModel] {
        guard let context = viewContext else {
            print ("CoreDataManager viewContext is nil")
            return []
        }
        
        let request = RouteEntity.fetchRequest()
        
        do {
            
            let routeEntities = try context.fetch(request)
            var routes = routeEntities.map { $0.model }
            for i in 0..<routes.count {
                routes[i].locations = routes[i].locations.sorted { $0.index! < $1.index! }
            }
            
            return routes
            
        } catch {
            print ("Could't load routes!")
        }
        
        return []
    }
    
    private func save() {
        do {
            try viewContext?.save()
        } catch {
            print ("Could't save data!")
        }
    }
}
