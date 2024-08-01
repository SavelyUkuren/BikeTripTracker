//
//  TestViewController.swift
//  BikeTripTracker
//
//  Created by Савелий Никулин on 01.08.2024.
//

import UIKit

class TestViewController: UIViewController {

	@IBOutlet weak var lineChartView: UIView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		let data: [CGFloat] = [0, 1, 2, 3, 4, 5]
		let data2: [CGFloat] = data//[0, 1, 2, 13, 17, 20]

		let xLabels: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
		
		let lineChart = LineChart(frame: lineChartView.frame)
		
		lineChart.animation.enabled = true
//		lineChart.area = true
		lineChart.x.labels.visible = true
//		lineChart.x.grid.count = 5
//		lineChart.y.grid.count = 5
		lineChart.x.labels.values = xLabels
		lineChart.colors = Array(repeating: UIColor.systemBlue, count: data.count)
		lineChart.dots.visible = false
//		lineChart.y.labels.visible = true
		lineChart.addLine(data)
		lineChart.addLine(data2)
		
		lineChart.translatesAutoresizingMaskIntoConstraints = false
		
		lineChartView.addSubview(lineChart)
        
		
		NSLayoutConstraint.activate([
			lineChart.topAnchor.constraint(equalTo: lineChartView.topAnchor),
			lineChart.leadingAnchor.constraint(equalTo: lineChartView.leadingAnchor),
			lineChart.trailingAnchor.constraint(equalTo: lineChartView.trailingAnchor),
			lineChart.heightAnchor.constraint(equalTo: lineChartView.heightAnchor)
		])
    }
    
}
