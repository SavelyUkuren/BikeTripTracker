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
    
}
