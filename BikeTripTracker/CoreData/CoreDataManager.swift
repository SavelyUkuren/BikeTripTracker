//
//  CoreDataManager.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//

import UIKit
import CoreData

class CoreDataManager {
    
    private var viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.newBackgroundContext()
    
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
            for location in route.locations {
                let lEntity = LocationEntity(context: context)
                lEntity.latitude = location.latitude
                lEntity.longitude = location.longitude
                lEntity.speed = location.speed ?? 0
                
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
            
            let routes = try context.fetch(request)
            
            return routes.map { $0.model }
            
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
