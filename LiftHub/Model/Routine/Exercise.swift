//
//  Exercise.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

struct Exercise {
    let exerciseType: ExerciseType
    var name: String
    let pause: Pause
    var load: Weight
    let series: Int
    let reps: Reps
    let intensity: Intensity?
    let pace: ExercisePace?
}
