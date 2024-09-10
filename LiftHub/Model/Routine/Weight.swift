//
//  Weight.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

struct Weight {
    let weight: Float
    let unit: WeightUnit

    // Custom string representation
    var description: String {
        return "\(weight)\(unit)"
    }

    // Private initializer to enforce validation
    private init(weight: Float, unit: WeightUnit) {
        self.weight = weight
        self.unit = unit
    }

    // Factory method using the invoke pattern in Swift
    static func create(weight: Float, unit: WeightUnit) -> Weight? {
        if weight < 0 {
            return nil
        } else {
            return Weight(weight: weight, unit: unit)
        }
    }

    // Function to create Weight from a string with unit
    static func fromStringWithUnit(_ weight: String?, unit: WeightUnit) throws -> Weight {
        guard let weight = weight, !weight.isEmpty else {
            throw ValidationException(message: "Weight cannot be empty")
        }

        guard let floatWeight = Float(weight) else {
            throw ValidationException(message: "Weight must be a number")
        }

        if floatWeight < 0 {
            throw ValidationException(message: "Weight cannot be negative")
        }

        return Weight(weight: floatWeight, unit: unit)
    }
}
