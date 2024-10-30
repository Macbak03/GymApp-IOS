//
//  Intensity.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

// Protocol to represent Intensity
protocol Intensity {
    var description: String { get }
}

// ExactIntensity struct
struct ExactIntensity: Intensity {
    let value: Int
    let index: IntensityIndex
    
    var description: String {
        return "\(value)"
    }
}

// RangeIntensity struct
struct RangeIntensity: Intensity {
    let from: Int
    let to: Int
    let index: IntensityIndex
    
    var description: String {
        return "\(from)-\(to)"
    }
}

struct IntensityFactory {
    // Helper function for Intensity creation
    static func fromString(_ intensity: String?, index: IntensityIndex) throws -> Intensity {
        guard let intensity = intensity else {
            throw ValidationException(message: "Intensity cannot be empty")
        }
        
        // Regex to match single values or ranges
        let regex = try! NSRegularExpression(pattern: "^([0-9]|10)$|^([0-9]|10)-([0-9]|10)$")
        let range = NSRange(location: 0, length: intensity.utf16.count)
        
        guard let match = regex.firstMatch(in: intensity, options: [], range: range) else {
            throw ValidationException(message: "Intensity must be a number (e.g., 7) or range (e.g., 7-8), numbers must be from 0 to 10")
        }
        
        let matchRangeFrom = match.range(at: 2) // Range for the first number
        let matchRangeTo = match.range(at: 3)   // Range for the second number
        
        if matchRangeFrom.location != NSNotFound && matchRangeTo.location != NSNotFound {
            // It's a range
            let rangeFrom = (intensity as NSString).substring(with: matchRangeFrom)
            let rangeTo = (intensity as NSString).substring(with: matchRangeTo)
            
            guard let intRangeFrom = Int(rangeFrom), let intRangeTo = Int(rangeTo), intRangeFrom < intRangeTo else {
                throw ValidationException(message: "The first number of the range must be lower than the second number")
            }
            
            return RangeIntensity(from: intRangeFrom, to: intRangeTo, index: index)
        } else {
            // It's an exact value
            let exactValue = (intensity as NSString).substring(with: match.range(at: 1))
            return ExactIntensity(value: Int(exactValue)!, index: index)
        }
    }
    
    static func fromStringForWorkout(_ intensity: String?, index: IntensityIndex) throws -> Intensity {
        guard let intensity = intensity else {
            throw ValidationException(message: "Intensity cannot be empty")
        }
        
        let regex = try! NSRegularExpression(pattern: "^([0-9]|10)$")
        let range = NSRange(location: 0, length: intensity.utf16.count)
        
        guard let match = regex.firstMatch(in: intensity, options: [], range: range) else {
            throw ValidationException(message: "Intensity must be a number (e.g., 7) number must be from 0 to 10")
        }
        
        let exactValue = (intensity as NSString).substring(with: match.range(at: 1))
        return ExactIntensity(value: Int(exactValue)!, index: index)
    }
}

