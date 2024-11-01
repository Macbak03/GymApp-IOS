//
//  TrainingPlan.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//

import Foundation

class TrainingPlan: Equatable, Hashable {
    var id = UUID()
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    var description: String {
        return name
    }
    
    static func == (lhs: TrainingPlan, rhs: TrainingPlan) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(name)
        }
}
