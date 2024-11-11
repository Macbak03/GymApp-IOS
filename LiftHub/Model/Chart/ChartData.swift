//
//  MarkerData.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 30/10/2024.
//

import Foundation

struct ChartData: Identifiable, Equatable {
    let id = UUID()
    let exerciseId: Int64
    let date: Date
    let reps: Double
    let weight: Weight
    
    static func mockData(year: Int, exerciseName: String, weightUnit: WeightUnit) -> [ChartData] {
        let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
        let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
    
        let exercises = workoutHistoryDatabaseHelper.getExercisesToChart(year: year, exerciseName: exerciseName)
        var data: [ChartData] = []
        
        for exercise in exercises {
            let exerciseId = exercise.exerciseId
            let series = workoutSeriesDatabaseHelper.getChartData(exerciseId: exerciseId)
            data.append(ChartData(exerciseId: exerciseId, date: exercise.date, reps: series.reps, weight: Weight(weight: series.weight, unit: weightUnit)))
        }
        
        return data
    }
    
    private func createCustomDate(year: Int, month: Int, day: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        // Use the current calendar to generate the date
        let calendar = Calendar.current
        return calendar.date(from: dateComponents)
    }
    
    
    static func generateTestData(year: Int) -> [ChartData] {
        let calendar = Calendar.current
        let chartData: [ChartData] = [
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2022, month: 08, day: 21)) ?? Date(), reps: 8, weight: Weight(weight: 50, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2022, month: 09, day: 21)) ?? Date(), reps: 8, weight: Weight(weight: 55, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2022, month: 10, day: 21)) ?? Date(), reps: 8, weight: Weight(weight: 60, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2023, month: 08, day: 21)) ?? Date(), reps: 8, weight: Weight(weight: 65, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2023, month: 09, day: 21)) ?? Date(), reps: 8, weight: Weight(weight: 70, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2023, month: 10, day: 21)) ?? Date(), reps: 8, weight: Weight(weight: 75, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 08, day: 21)) ?? Date(), reps: 8, weight: Weight(weight: 80, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 08, day: 27)) ?? Date(), reps: 8, weight: Weight(weight: 85, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 09, day: 02)) ?? Date(), reps: 8, weight: Weight(weight: 90, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 09, day: 10)) ?? Date(), reps: 8, weight: Weight(weight: 80, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 09, day: 16)) ?? Date(), reps: 8, weight: Weight(weight: 85, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 09, day: 21)) ?? Date(), reps: 8, weight: Weight(weight: 90, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 09, day: 28)) ?? Date(), reps: 8, weight: Weight(weight: 80, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 10, day: 04)) ?? Date(), reps: 8, weight: Weight(weight: 85, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 10, day: 12)) ?? Date(), reps: 8, weight: Weight(weight: 90, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 10, day: 19)) ?? Date(), reps: 8, weight: Weight(weight: 80, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 10, day: 25)) ?? Date(), reps: 8, weight: Weight(weight: 85, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 10, day: 30)) ?? Date(), reps: 8, weight: Weight(weight: 90, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 11, day: 05)) ?? Date(), reps: 8, weight: Weight(weight: 80, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 11, day: 14)) ?? Date(), reps: 8, weight: Weight(weight: 85, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 11, day: 22)) ?? Date(), reps: 8, weight: Weight(weight: 90, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 11, day: 29)) ?? Date(), reps: 8, weight: Weight(weight: 80, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 12, day: 03)) ?? Date(), reps: 8, weight: Weight(weight: 85, unit: WeightUnit.kg)),
            .init(exerciseId: 1, date: calendar.date(from: DateComponents(year: 2024, month: 12, day: 10)) ?? Date(), reps: 8, weight: Weight(weight: 90, unit: WeightUnit.kg)),
        ]
        
        return chartData.filter { data in
            let dataYear = calendar.component(.year, from: data.date)
            return dataYear == year
        }
    }
}
