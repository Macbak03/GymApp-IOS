//
//  WeightUnit.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

enum WeightUnit: String, CaseIterable, Codable {
    case kg = "kg"
    case lbs = "lbs"
    
    var description: String {
        switch self {
        case .kg: return "kg"
        case .lbs: return "lbs"
        }
    }
}
