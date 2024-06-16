//
//  UIFont.swift
//  BikeTripTracker
//
//  Created by Савелий Никулин on 16.06.2024.
// https://stackoverflow.com/a/65217577

import Foundation
import UIKit

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)

        guard #available(iOS 13.0, *), let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else { return systemFont }
        return UIFont(descriptor: descriptor, size: size)
    }
}
