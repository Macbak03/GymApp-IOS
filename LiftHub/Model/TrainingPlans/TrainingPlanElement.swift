//
//  TrainingPlanElement.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import Foundation

class TrainingPlanElement: Equatable {
    var id = UUID()
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    var description: String {
        return name
    }
    
    static func == (lhs: TrainingPlanElement, rhs: TrainingPlanElement) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
