//
//  RoutesViewController.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//

import UIKit

class RoutesViewController: UIViewController {

    @IBOutlet weak var routesTableView: UITableView!
    
    private var routes: [RouteModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureRoutesTableView()
        loadRoutes()
    }
    
    private func configureRoutesTableView() {
        routesTableView.delegate = self
        routesTableView.dataSource = self
    }
    
    private func loadRoutes() {
        let coreDataManager = CoreDataManager()
        
        routes = coreDataManager.loadRoutes()
    }
    
    private func deleteRoute(_ indexPath: IndexPath) {
        let route = self.routes[indexPath.row]
        
        routes.remove(at: indexPath.row)
        routesTableView.deleteRows(at: [indexPath], with: .automatic)
        routesTableView.reloadData()
        
        let coreDataManager = CoreDataManager()
        coreDataManager.deleteRoute(route)
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension RoutesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RouteTableViewCell
        
        let route = routes[indexPath.row]
        cell.setRoute(route)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let routeDetailVC = storyboard.instantiateViewController(withIdentifier: "RouteDetailVC") as? RouteDetailViewController {
            routeDetailVC.route = routes[indexPath.row]
            
            navigationController?.pushViewController(routeDetailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.deleteRoute(indexPath)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
}
