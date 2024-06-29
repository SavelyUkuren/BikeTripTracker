//
//  Settings.swift
//  BikeTripTracker
//
//  Created by savik on 21.05.2024.
//

import Foundation

class Settings {
    static var shared = Settings()
    
    enum Keys: String {
        case appearance
        case speedMeasureUnit
        case distanceMeasureUnit
    }
    
    var appearance: AppearanceMode = .system {
        didSet { 
            settingsDidUpdate()
            save(Keys.appearance.rawValue, appearance.rawValue)
        }
    }
    
    var speedMeasureUnit: SpeedMeasureUnit = .kilometersPerHour {
        didSet { 
            settingsDidUpdate()
            save(Keys.speedMeasureUnit.rawValue, speedMeasureUnit.rawValue)
        }
    }
    
    var distanceMeasureUnit: DistanceMeasureUnit = .kilometers {
        didSet { 
            settingsDidUpdate()
            save(Keys.distanceMeasureUnit.rawValue, distanceMeasureUnit.rawValue)
        }
    }
    
    init() {
        load()
    }
    
    private func settingsDidUpdate() {
        NotificationCenter.default.post(name: NSNotification.Name("SettingsDidUpdate"), object: nil)
    }
    
    private func save(_ key: String, _ value: Any) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    private func load() {
        let appearance = AppearanceMode(rawValue: UserDefaults.standard.integer(forKey: Keys.appearance.rawValue)) ?? .system
        self.appearance = appearance
        
        if let savedSpeedMesureUnit = UserDefaults.standard.string(forKey: Keys.speedMeasureUnit.rawValue) {
            let speedMeasureUnit = SpeedMeasureUnit(rawValue:  savedSpeedMesureUnit) ?? .kilometersPerHour
            self.speedMeasureUnit = speedMeasureUnit
        }
        
        if let savedDistanceMeasureUnit = UserDefaults.standard.string(forKey: Keys.distanceMeasureUnit.rawValue) {
            let distanceMeasureUnit = DistanceMeasureUnit(rawValue: savedDistanceMeasureUnit) ?? .kilometers
            self.distanceMeasureUnit = distanceMeasureUnit
        }
    }
}
