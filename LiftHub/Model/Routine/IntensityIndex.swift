//
//  IntensityIndex.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

enum IntensityIndex: String {
    case RPE = "RPE"
    case RIR = "RIR"
    
    var descritpion: String {
        switch self {
        case .RPE: return "RPE"
        case .RIR: return "RIR"
        }
    }
}
