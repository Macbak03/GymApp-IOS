//
//  RoutineViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 21/11/2024.
//

import Foundation

class RoutineViewModel: ObservableObject {
    @Published var routine: TrainingPlanElement = TrainingPlanElement(name: "")
    
    func initRoutine(routine: TrainingPlanElement) {
        self.routine = routine
    }
}
