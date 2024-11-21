//
//  Pause.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

// Protocol to represent Pause
protocol Pause {
    var description: String { get }
}

// ExactPause struct
struct ExactPause: Pause {
    let value: Int
    let pauseUnit: TimeUnit

    var description: String {
        return "\(value)"
    }
}

// RangePause struct
struct RangePause: Pause {
    let from: Int
    let to: Int
    let pauseUnit: TimeUnit

    var description: String {
        return "\(from)-\(to)"
    }
}
struct PauseFactory {
    // Helper function to create Pause from String
    static func fromString(_ pause: String?, unit: TimeUnit) throws -> Pause {
        guard let pause = pause, !pause.isEmpty else {
            throw ValidationException(message: "Rest cannot be empty")
        }
        
        // Regular expression to match exact or range values
        let regex = try! NSRegularExpression(pattern: #"^(\d+)$|^(\d+)-(\d+)$"#)
        let range = NSRange(location: 0, length: pause.utf16.count)
        
        guard let match = regex.firstMatch(in: pause, options: [], range: range) else {
            throw ValidationException(message: "Rest must be a number (e.g., 5) or range (e.g., 3-5) and cannot be negative")
        }
        
        let seconds = 60
        
        let matchExactValueRange = match.range(at: 1)
        let matchRangeFromRange = match.range(at: 2)
        let matchRangeToRange = match.range(at: 3)
        
        // Case 1: Range match (from-to)
        if matchRangeFromRange.location != NSNotFound && matchRangeToRange.location != NSNotFound {
            let rangeFrom = (pause as NSString).substring(with: matchRangeFromRange)
            let rangeTo = (pause as NSString).substring(with: matchRangeToRange)
            
            guard let intRangeFrom = Int(rangeFrom), let intRangeTo = Int(rangeTo), intRangeFrom < intRangeTo else {
                throw ValidationException(message: "First number of the range must be lower than the second number")
            }
            
            if unit == .min {
                if intRangeFrom > 60 {
                    throw ValidationException(message: "Why go to the gym if you're resting for that long between sets???")
                }
                return RangePause(from: intRangeFrom * seconds, to: intRangeTo * seconds, pauseUnit: unit)
            } else {
                if intRangeFrom > 3600 {
                    throw ValidationException(message: "Why go to the gym if you're resting for that long between sets???")
                }
                return RangePause(from: intRangeFrom, to: intRangeTo, pauseUnit: unit)
            }
        }
        // Case 2: Exact value match
        else if matchExactValueRange.location != NSNotFound {
            let exactValue = (pause as NSString).substring(with: matchExactValueRange)
            if let intValue = Int(exactValue) {
                if unit == .min {
                    if intValue > 60 {
                        throw ValidationException(message: "Why go to the gym if you're resting for that long between sets???")
                    }
                    return ExactPause(value: intValue * seconds, pauseUnit: unit)
                } else {
                    if intValue > 3600 {
                        throw ValidationException(message: "Why go to the gym if you're resting for that long between sets???")
                    }
                    return ExactPause(value: intValue, pauseUnit: unit)
                }
            }
        }
        
        // If nothing matched, throw an error
        throw ValidationException(message: "Rest must be a valid number or range")
    }
    
}

