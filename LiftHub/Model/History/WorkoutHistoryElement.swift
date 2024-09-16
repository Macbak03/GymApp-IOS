//
//  WorkoutHistoryElement.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 16/09/2024.
//

import Foundation

struct WorkoutHistoryElement {
    let planName: String
    let routineName: String
    let formattedDate: String
    let rawDate: String
    
    init(planName: String, routineName: String, formattedDate: String, rawDate: String) {
        self.planName = planName
        self.routineName = routineName
        self.formattedDate = formattedDate
        self.rawDate = rawDate
    }
}
