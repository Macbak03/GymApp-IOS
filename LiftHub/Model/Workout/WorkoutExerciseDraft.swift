//
//  WorkoutExerciseDraft.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 13/09/2024.
//

import Foundation

struct WorkoutExerciseDraft {
    var id = UUID()
    var name: String
    var pause: String
    var pauseUnit: TimeUnit
    var series: String
    var reps: String
    var intensity: String
    var intensityIndex: IntensityIndex
    var pace: String

    init(name: String, pause: String, pauseUnit: TimeUnit, series: String, reps: String, intensity: String, intensityIndex: IntensityIndex, pace: String) {
        self.name = name
        self.pause = pause
        self.pauseUnit = pauseUnit
        self.series = series
        self.reps = reps
        self.intensity = intensity
        self.intensityIndex = intensityIndex
        self.pace = pace
    }
}
