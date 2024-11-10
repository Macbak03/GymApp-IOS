//
//  MarkerData.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 30/10/2024.
//

import Foundation

struct ChartData: Identifiable {
    let id = UUID()
    let exerciseId: Int64
    let date: Date
    let reps: Double
    let weight: Weight
    
    static func mockData(exerciseName: String, weightUnit: WeightUnit) -> [ChartData] {
        let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
        let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
        let exercises = workoutHistoryDatabaseHelper.getExercisesToChart(exerciseName: exerciseName)
        var data: [ChartData] = []
        
        for exercise in exercises {
            let exerciseId = exercise.exerciseId
            let series = workoutSeriesDatabaseHelper.getChartData(exerciseId: exerciseId)
            data.append(ChartData(exerciseId: exerciseId, date: exercise.date, reps: series.reps, weight: Weight(weight: series.weight, unit: weightUnit)))
        }
        
        return data
    }
}
