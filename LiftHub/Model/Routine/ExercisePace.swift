//
//  ExercisePace.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

import Foundation

protocol Pace {
    var description: String { get }
}

struct NumericPace: Pace {
    let value: Int

    var description: String {
        return "\(value)"
    }
}

class MaxPace: Pace {
    static let shared = MaxPace()
    private init() {}

    var description: String {
        return "x"
    }
}

// Helper function to handle 'fromChar' logic
func paceFromChar(_ pace: Character) throws -> Pace {
    if let intPace = pace.wholeNumberValue {
        return NumericPace(value: intPace)
    } else if pace == "x" {
        return MaxPace.shared
    } else {
        throw ValidationException(message: "Pace must be in correct form, e.g., 21x1")
    }
}

struct ExercisePace {
    let eccentricPhase: Pace
    let midLiftPause: Pace
    let concentricPhase: Pace
    let endLiftPause: Pace

    var description: String {
        return "\(eccentricPhase.description)\(midLiftPause.description)\(concentricPhase.description)\(endLiftPause.description)"
    }

    static func fromString(_ pace: String?, position: Int = 0) throws -> ExercisePace {
        guard let pace = pace, !pace.isEmpty else {
            throw ValidationException(message: "Pace cannot be empty", position: position)
        }

        let regex = try! NSRegularExpression(pattern: "^[x\\d]{4}$")
        let range = NSRange(location: 0, length: pace.utf16.count)

        guard regex.firstMatch(in: pace, options: [], range: range) != nil else {
            throw ValidationException(message: "Pace must be in correct form, e.g., 21x1", position: position)
        }

        return ExercisePace(
            eccentricPhase: try paceFromChar(pace[pace.index(pace.startIndex, offsetBy: 0)]),
            midLiftPause: try paceFromChar(pace[pace.index(pace.startIndex, offsetBy: 1)]),
            concentricPhase: try paceFromChar(pace[pace.index(pace.startIndex, offsetBy: 2)]),
            endLiftPause: try paceFromChar(pace[pace.index(pace.startIndex, offsetBy: 3)])
        )
    }
}


