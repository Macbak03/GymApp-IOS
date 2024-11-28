//
//  HistoryDetailsElementViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 22/11/2024.
//

import Foundation

class HistoryDetailsElementViewModel: ObservableObject {
    @Published var exercise: WorkoutDraft
    let planName: String
    
    init(exercise: WorkoutDraft, planName: String) {
        self.exercise = exercise
        self.planName = planName
    }
}
