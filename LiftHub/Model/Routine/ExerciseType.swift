//
//  ExerciseType.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 19/07/2025.
//

enum ExerciseType: String, Codable, CaseIterable {
    case weighted = "weighted"
    case timed = "timed"
    //case dropset = "drop set"
    
    var description: String {
        switch self {
        case .weighted: return "weighted"
        case .timed: return "timed"
        //case .dropset: return "drop set"
        }
    }
}
