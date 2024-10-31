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
        
//        return [
//            .init(exerciseId: 1, date: Calendar.current.date(from: DateComponents(month: 08, day: 29)) ?? Date(), reps: 8, weight: Weight(weight: 50, unit: WeightUnit.kg)),
//            .init(exerciseId: 1, date: Calendar.current.date(from: DateComponents(month: 08, day: 31)) ?? Date(), reps: 7, weight: Weight(weight: 55, unit: WeightUnit.kg)),
//            .init(exerciseId: 1, date: Calendar.current.date(from: DateComponents(month: 09, day: 02)) ?? Date(), reps: 7, weight: Weight(weight: 57.5, unit: WeightUnit.kg)),
//            .init(exerciseId: 1, date: Calendar.current.date(from: DateComponents(month: 09, day: 10)) ?? Date(), reps: 8, weight: Weight(weight: 60, unit: WeightUnit.kg)),
//            .init(exerciseId: 1, date: Calendar.current.date(from: DateComponents(month: 09, day: 15)) ?? Date(), reps: 6, weight: Weight(weight: 62.5, unit: WeightUnit.kg)),
//            .init(exerciseId: 1, date: Calendar.current.date(from: DateComponents(month: 09, day: 25)) ?? Date(), reps: 8, weight: Weight(weight: 62.5, unit: WeightUnit.kg)),
//            .init(exerciseId: 1, date: Calendar.current.date(from: DateComponents(month: 10, day: 01)) ?? Date(), reps: 8, weight: Weight(weight: 60, unit: WeightUnit.kg)),
//            .init(exerciseId: 1, date: Calendar.current.date(from: DateComponents(month: 10, day: 07)) ?? Date(), reps: 9, weight: Weight(weight: 62.5, unit: WeightUnit.kg)),
//            .init(exerciseId: 1, date: Calendar.current.date(from: DateComponents(month: 10, day: 12)) ?? Date(), reps: 6, weight: Weight(weight: 70, unit: WeightUnit.kg)),
//            .init(exerciseId: 1, date: Calendar.current.date(from: DateComponents(month: 10, day: 21)) ?? Date(), reps: 7, weight: Weight(weight: 72.5, unit: WeightUnit.kg))
//        ]
    }
}
