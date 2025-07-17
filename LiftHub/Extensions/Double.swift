//
//  Double.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 16/07/2025.
//

import Foundation

extension Double {
    var toStringWithFormat: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
