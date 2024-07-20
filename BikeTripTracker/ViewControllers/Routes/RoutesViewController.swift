//
//  RoutesViewController.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//

import UIKit

class RoutesViewController: UIViewController {

    @IBOutlet weak var routesTableView: UITableView!
    
    private var routes: [RoutesRow] = []
    private var routeDetailIsLoaded = false
    private var selectedRouteCellIndex: IndexPath?

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
        
        let allRoutes = coreDataManager.loadRoutes()
        
        let groupedRoutes = Dictionary(grouping: allRoutes) { route in
            Calendar.current.dateComponents([.month, .year], from: route.date)
        }
        
        let formatter = DateFormatter()
        for (components, routes) in groupedRoutes {
            
            let monthTitle = formatter.monthSymbols[components.month! - 1]
            let year = components.year!
            let sortedRoutes = routes.sorted { $0.date > $1.date }
            let totalDistance = routes.reduce(0, { $0 + $1.distance })
            
            let routesRow = RoutesRow(title: "\(monthTitle) \(year)",
									  monthNumber: components.month!, year: year,
                                      totalDistance: totalDistance, routes: sortedRoutes)
            
            self.routes.append(routesRow)
        }
		
		// Sorting from the last route added to the first route added
		routes = routes.sorted(by: { (route1, route2) -> Bool in
			if route1.year == route2.year {
				return route1.monthNumber > route2.monthNumber
			} else {
				return route1.year > route2.year
			}
		})
        
    }
    
    private func deleteRoute(_ indexPath: IndexPath) {
        let route = self.routes[indexPath.section].routes[indexPath.row]
        
        routes[indexPath.section].routes.remove(at: indexPath.row)
        
        routesTableView.beginUpdates()
        
        routesTableView.deleteRows(at: [indexPath], with: .automatic)
        
        if routes[indexPath.section].routes.isEmpty {
            routes.remove(at: indexPath.section)
            routesTableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
        
        routesTableView.endUpdates()
        
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
        routes[section].routes.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RouteTableViewCell
        
        let route = routes[indexPath.section].routes[indexPath.row]
        cell.setRoute(route)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let routeDetailVC = storyboard.instantiateViewController(withIdentifier: "RouteDetailVC") as? RouteDetailViewController {
            selectedRouteCellIndex = indexPath
            routeDetailVC.route = routes[indexPath.section].routes[indexPath.row]
            
            navigationController?.pushViewController(routeDetailVC, animated: true)
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = RoutesTableViewHeader(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.route = self.routes[section]
        return view
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
