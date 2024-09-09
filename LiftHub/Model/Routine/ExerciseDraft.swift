//
//  Exercise.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import Foundation

class ExerciseDraft {
    var name: String?
    var pause: String?
    //var pauseUnit: TimeUnit
    var load: String?
    //var loadUnit: WeightUnit
    var series: String?
    var reps: String?
    var intensity: String?
    //var intensityIndex: IntensityIndex
    var pace: String?
    var wasModified: Bool
    
    init(name: String?, pause: String?, load: String?, series: String?, reps: String?, intensity: String?, pace: String?, wasModified: Bool) {
        self.name = name
        self.pause = pause
        self.load = load
        self.series = series
        self.reps = reps
        self.intensity = intensity
        self.pace = pace
        self.wasModified = wasModified
    }
}
