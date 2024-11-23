//
//  WorkoutExerciseViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 23/11/2024.
//

import Foundation

class WorkoutExerciseViewModel: ObservableObject {
    @Published var exerciseName = "Exercise"
    
    @Published var intensityIndexText = "Intensity"
    @Published var restValue = "val"
    @Published var restUnit = "val"
    @Published var seriesValue = "val"
    @Published var intensityValue = "val"
    @Published var paceValue = "val"
    
    @Published var noteHint: String = "Note"
    
    
    func initValues(workoutExerciseDraft: WorkoutExerciseDraft, workoutHints: WorkoutHints) {
        self.exerciseName = workoutExerciseDraft.name
        self.intensityIndexText = workoutExerciseDraft.intensityIndex.rawValue
        self.restValue = workoutExerciseDraft.pause
        self.restUnit = workoutExerciseDraft.pauseUnit.rawValue
        self.seriesValue = workoutExerciseDraft.series
        self.intensityValue = workoutExerciseDraft.intensity
        self.paceValue = workoutExerciseDraft.pace
        self.noteHint = workoutHints.noteHint
    }
}
