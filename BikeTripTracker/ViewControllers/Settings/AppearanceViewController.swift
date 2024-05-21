//
//  AppearanceViewController.swift
//  BikeTripTracker
//
//  Created by savik on 21.05.2024.
//

import UIKit

class AppearanceViewController: UITableViewController {

    enum AppearanceSections: Int {
        case appearance
    }
    
    @IBOutlet var appearanceTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCells()
    }
    
    private func setupCells() {
        let appearanceIndexPath = IndexPath(row: Settings.shared.appearance.rawValue,
                                            section: AppearanceSections.appearance.rawValue)
        appearanceTableView.cellForRow(at: appearanceIndexPath)?.accessoryType = .checkmark
    }
    
    private func updateAppearance() {
        let sceneDelegate = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)
        sceneDelegate?.appearanceSetup()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Clear checkmark
        let cellCount = tableView.numberOfRows(inSection: AppearanceSections.appearance.rawValue)
        for index in 0..<cellCount {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: AppearanceSections.appearance.rawValue))
            cell?.accessoryType = .none
            cell?.selectionStyle = .none
        }
        
        // Set checkmark
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        let newAppearance = AppearanceMode(rawValue: indexPath.row) ?? .system
        Settings.shared.appearance = newAppearance
        
        updateAppearance()
    }

}
