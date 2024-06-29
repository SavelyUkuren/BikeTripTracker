//
//  UnitsOfMeasureViewController.swift
//  BikeTripTracker
//
//  Created by savik on 21.05.2024.
//

import UIKit

class UnitsOfMeasureViewController: UITableViewController {
    
    enum UnitsOfMeasureSections: Int {
        case speed, distance
    }
    
    @IBOutlet var unitOfMeasureTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCells()
    }
    
    private func setupCells() {
        let speedIndexInEnum = SpeedMeasureUnit.allCases.firstIndex(of: Settings.shared.speedMeasureUnit) ?? 0
        let speedIndexPath = IndexPath(row: speedIndexInEnum,
                                       section: UnitsOfMeasureSections.speed.rawValue)
        unitOfMeasureTableView.cellForRow(at: speedIndexPath)?.accessoryType = .checkmark
        
        let distanceIndexInEnum = DistanceMeasureUnit.allCases.firstIndex(of: Settings.shared.distanceMeasureUnit) ?? 0
        let distaneIndexPath = IndexPath(row: distanceIndexInEnum,
                                         section: UnitsOfMeasureSections.distance.rawValue)
        unitOfMeasureTableView.cellForRow(at: distaneIndexPath)?.accessoryType = .checkmark
    }
    
    private func clearCellFromCheckmarks(_ tableView: UITableView, _ section: UnitsOfMeasureSections) {
        
        let cellCount = tableView.numberOfRows(inSection: section.rawValue)
        for index in 0..<cellCount {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: section.rawValue))
            cell?.accessoryType = .none
            cell?.selectionStyle = .none
        }
        
    }
    
    private func selectCell(_ tableView: UITableView, _ indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case UnitsOfMeasureSections.speed.rawValue:
            clearCellFromCheckmarks(tableView,  UnitsOfMeasureSections.speed)
            Settings.shared.speedMeasureUnit = SpeedMeasureUnit.allCases[indexPath.row]
            break
        case UnitsOfMeasureSections.distance.rawValue:
            clearCellFromCheckmarks(tableView,  UnitsOfMeasureSections.distance)
            Settings.shared.distanceMeasureUnit = DistanceMeasureUnit.allCases[indexPath.row]
            break
        default:
            break
        }
        
        selectCell(tableView, indexPath)
    }

}
