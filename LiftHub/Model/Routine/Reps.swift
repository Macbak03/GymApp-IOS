//
//  Reps.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

// Protocol to represent Reps
protocol Reps {
    var description: String { get }
}

// ExactReps struct
struct ExactReps: Reps {
    let value: Int

    var description: String {
        return "\(value)"
    }
}

// RangeReps struct
struct RangeReps: Reps {
    let from: Int
    let to: Int

    var description: String {
        return "\(from)-\(to)"
    }
}
struct RepsFactory {
    // Helper function to create Reps from String
    static func fromString(_ reps: String?) throws -> Reps {
        guard let reps = reps, !reps.isEmpty else {
            throw ValidationException(message: "Reps cannot be empty")
        }
        
        // Regular expression to match exact or range values
        let regex = try! NSRegularExpression(pattern: #"^(\d+)$|^(\d+)-(\d+)$"#)
        let range = NSRange(location: 0, length: reps.utf16.count)
        
        guard let match = regex.firstMatch(in: reps, options: [], range: range) else {
            throw ValidationException(message: "Reps must be a number (e.g., 5) or range (e.g., 3-5) and cannot be negative")
        }
        
        let matchExactValueRange = match.range(at: 1)
        let matchRangeFromRange = match.range(at: 2)
        let matchRangeToRange = match.range(at: 3)
        
        // Case 1: Range match (from-to)
        if matchRangeFromRange.location != NSNotFound && matchRangeToRange.location != NSNotFound {
            let rangeFrom = (reps as NSString).substring(with: matchRangeFromRange)
            let rangeTo = (reps as NSString).substring(with: matchRangeToRange)
            
            guard let intRangeFrom = Int(rangeFrom), let intRangeTo = Int(rangeTo), intRangeFrom < intRangeTo else {
                throw ValidationException(message: "First number of the range must be lower than the second number")
            }
            
            return RangeReps(from: intRangeFrom, to: intRangeTo)
        }
        // Case 2: Exact value match
        else if matchExactValueRange.location != NSNotFound {
            let exactValue = (reps as NSString).substring(with: matchExactValueRange)
            
            if let intValue = Int(exactValue) {
                return ExactReps(value: intValue)
            }
        }
        
        // If nothing matched, throw an error
        throw ValidationException(message: "Reps must be a valid number or range")
    }
}
