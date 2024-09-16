//
//  WorkoutExercise.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 15/09/2024.
//

import Foundation

struct WorkoutExercise {
    var exercise: Exercise
    var exerciseCount: Int
    var note: String
    
    init(exercise: Exercise, exerciseCount: Int, note: String) {
        self.exercise = exercise
        self.exerciseCount = exerciseCount
        self.note = note
    }
}
