//
//  EditHistoryDetailsElementViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 22/11/2024.
//

import Foundation

class EditHistoryDetailsElementViewModel: ObservableObject {
    let planName: String
    let position: Int
    
    @Published var exerciseName = "Exercise"
    
    @Published var intensityIndexText = "Intensity"
    @Published var restValue = "val"
    @Published var restUnit = "val"
    @Published var seriesValue = "val"
    @Published var intensityValue: String? = "val"
    @Published var paceValue: String? = "val"
    
    @Published var noteHint = "Note"
    
    @Published var volumeValue: Double = 0.0
    
    init(planName: String, position: Int) {
        self.planName = planName
        self.position = position
    }
    
    func initValues(workoutExerciseDraft: WorkoutExerciseDraft) {
        self.exerciseName = workoutExerciseDraft.name
        self.intensityIndexText = workoutExerciseDraft.intensityIndex.rawValue
        self.restValue = workoutExerciseDraft.pause
        self.restUnit = workoutExerciseDraft.pauseUnit.rawValue
        self.seriesValue = workoutExerciseDraft.series
        self.intensityValue = workoutExerciseDraft.intensity
        self.paceValue = workoutExerciseDraft.pace
    }
}
