//
//  Weight.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

struct Weight: Equatable {
    let weight: Double
    let unit: WeightUnit

    // Custom string representation
    var description: String {
        return "\(weight)\(unit)"
    }

    // Private initializer to enforce validation
    init(weight: Double, unit: WeightUnit) {
        self.weight = weight
        self.unit = unit
    }

    // Factory method using the invoke pattern in Swift
    static func create(weight: Double, unit: WeightUnit) -> Weight? {
        if weight < 0 {
            return nil
        } else {
            return Weight(weight: weight, unit: unit)
        }
    }

    // Function to create Weight from a string with unit
    static func fromStringWithUnit(_ weight: String?, unit: WeightUnit) throws -> Weight {
        guard let weight = weight, !weight.isEmpty else {
            throw ValidationException(message: "Load cannot be empty")
        }

        guard let doubleWeight = Double(weight) else {
            throw ValidationException(message: "Load must be a number")
        }
        
        if unit == .kg {
            if doubleWeight > 5000 {
                throw ValidationException(message: "If you really lift that much, send me a video and I'll change the limit.")
            }
        } else if unit == .lbs {
            if doubleWeight > 10000 {
                throw ValidationException(message: "If you really lift that much, send me a video and i will change the limit.")
            }
        }

        if doubleWeight < 0 {
            throw ValidationException(message: "Load cannot be negative")
        }

        return Weight(weight: doubleWeight, unit: unit)
    }
}
