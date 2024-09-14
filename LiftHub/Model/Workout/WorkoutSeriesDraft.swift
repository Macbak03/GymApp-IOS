//
//  WorkoutSeriesDraft.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 13/09/2024.
//

import Foundation

struct WorkoutSeriesDraft: Codable {
    var id = UUID()
    var actualReps: String
    var actualLoad: String
    var loadUnit: WeightUnit
    var intensityIndex: IntensityIndex
    var actualIntensity: String
    
    init(id: UUID = UUID(), actualReps: String, actualLoad: String, loadUnit: WeightUnit, intensityIndex: IntensityIndex, actualIntensity: String) {
        self.id = id
        self.actualReps = actualReps
        self.actualLoad = actualLoad
        self.loadUnit = loadUnit
        self.intensityIndex = intensityIndex
        self.actualIntensity = actualIntensity
    }
    
    func toWorkoutSeries(seriesCount: Int) throws -> WorkoutSeries {
        if actualReps.isEmpty {
            throw ValidationException(message: "Reps cannot be empty")
        }
        guard let floatReps = Float(actualReps) else {
            throw ValidationException(message: "Reps must be a number")
        }
        let load = try Weight.fromStringWithUnit(actualLoad, unit: loadUnit)
        let intensity = try IntensityFactory.fromString(actualIntensity, index: intensityIndex)
        
        return WorkoutSeries(actualReps: floatReps, seriesCount: seriesCount, load: load, actualIntensity: intensity)
    }
}