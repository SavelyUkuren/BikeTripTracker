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
    
}
