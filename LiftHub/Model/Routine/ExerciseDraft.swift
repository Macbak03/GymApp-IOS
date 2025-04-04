//
//  Exercise.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import Foundation

class ExerciseDraft: ObservableObject, Identifiable {
    @Published var id = UUID()
    @Published var name: String
    @Published var pause: String
    @Published var pauseUnit: TimeUnit
    @Published var load: String
    @Published var loadUnit: WeightUnit
    @Published var series: String
    @Published var reps: String
    @Published var intensity: String
    @Published var intensityIndex: IntensityIndex
    @Published var pace: String
    @Published var wasModified: Bool
    
    init(name: String, pause: String, pauseUnit: TimeUnit, load: String, loadUnit: WeightUnit, series: String, reps: String, intensity: String, intensityIndex: IntensityIndex, pace: String, wasModified: Bool) {
        self.name = name
        self.pause = pause
        self.pauseUnit = pauseUnit
        self.load = load
        self.loadUnit = loadUnit
        self.series = series
        self.reps = reps
        self.intensity = intensity
        self.intensityIndex = intensityIndex
        self.pace = pace
        self.wasModified = wasModified
    }
    
    func toExercise() throws -> Exercise {
        // Validate name
        if name.isEmpty {
            throw ValidationException(message: "Exercise name cannot be empty")
        }

        // Convert pause, weight, reps, intensity, and pace with appropriate error handling
        let pauseDuration = try PauseFactory.fromString(pause, unit: pauseUnit)
        let weight = try Weight.fromStringWithUnit(load, unit: loadUnit)
        let reps = try RepsFactory.fromString(reps)

        // Validate series
        if series.isEmpty {
            throw ValidationException(message: "Series cannot be empty")
        }

        guard let intSeries = Int(series) else {
            throw ValidationException(message: "Series must be a number")
        }
        
        if intSeries > 50 {
            throw ValidationException(message: "Sorry, can't let you create this many series because the app will crash")
        }

        // Convert intensity and pace
        let intensity = try IntensityFactory.fromString(intensity, index: intensityIndex)
        let pace = try ExercisePace.fromString(pace)

        // Create and return an Exercise instance
        return Exercise(name: name, pause: pauseDuration, load: weight, series: intSeries, reps: reps, intensity: intensity, pace: pace)
    }

}
