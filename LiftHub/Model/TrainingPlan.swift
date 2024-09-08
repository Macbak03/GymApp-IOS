//
//  TrainingPlan.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//

import Foundation

class TrainingPlan: Identifiable {
    var id = UUID()
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    var description: String {
        return name
    }
}
