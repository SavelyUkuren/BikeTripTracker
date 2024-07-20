//
//  UILabel.swift
//  BikeTripTracker
//
//  Created by Савелий Никулин on 19.07.2024.
//

import UIKit

extension UILabel {
	@IBInspectable var localizationKey: String? {
		get { return nil }
		set {
			if let key = newValue {
				text = NSLocalizedString(key, comment: "")
			}
		}
	}
}
