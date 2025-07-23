//
//  TimeUnit.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

enum TimeUnit : String, CaseIterable, Codable {
    case min = "min"
    case s = "s"
    
    var description: String {
        switch self {
        case .min: return "min"
        case .s: return "s"
        }
    }
}
