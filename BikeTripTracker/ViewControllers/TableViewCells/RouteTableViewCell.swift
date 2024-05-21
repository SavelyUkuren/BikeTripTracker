//
//  RouteTableViewCell.swift
//  BikeTripTracker
//
//  Created by savik on 19.05.2024.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setRoute(_ route: RouteModel) {
        let distanceMeasureUnit = RouteTracker.shared.distanceMeasureUnit == .meters ? "m" : "km"
        
        let distance = RouteTracker.shared.distanceMeasureUnit == .meters ? route.distance : route.distance / 1000
        
        dateLabel.text = formatDate(date: route.date)
        distanceLabel.text = "\(distance.round(to: 2)) \(distanceMeasureUnit)"
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        
        return dateFormatter.string(from: date)
    }
    
}
