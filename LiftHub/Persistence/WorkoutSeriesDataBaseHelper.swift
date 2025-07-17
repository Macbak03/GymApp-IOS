//
//  WorkoutSeriesDataBaseHelper.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 15/09/2024.
//

import Foundation
import SQLite

class WorkoutSeriesDataBaseHelper : Repository{
    static let TABLE_NAME = "workoutSeries"
    static let EXERCISE_ID_COLUMN = "exerciseID"
    static let SERIES_ORDER_COLUMN = "seriesOrder"
    static let ACTUAL_REPS_COLUMN = "actualReps"
    static let LOAD_VALUE_COLUMN = "loadValue"
    static let INTENSITY_VALUE = "intensityValue"

    // Define table and columns
    private let workoutSeriesTable = Table(TABLE_NAME)
    private let exerciseId = SQLite.Expression<Int64>(EXERCISE_ID_COLUMN)
    private let seriesOrder = SQLite.Expression<Int64>(SERIES_ORDER_COLUMN)
    private let actualReps = SQLite.Expression<Double>(ACTUAL_REPS_COLUMN)
    private let loadValue = SQLite.Expression<Double>(LOAD_VALUE_COLUMN)
    private let intensityValue = SQLite.Expression<Int>(INTENSITY_VALUE)
    
    private let workoutHistoryTable = Table(WorkoutHistoryDataBaseHelper.TABLE_NAME)
    private let workoutHistoryExericseId = SQLite.Expression<Int64>(WorkoutHistoryDataBaseHelper.EXERCISE_ID_COLUMN)
    private let workoutHistoryLoadUnit = SQLite.Expression<String>(WorkoutHistoryDataBaseHelper.LOAD_UNIT_COLUMN)
    private let workoutHistoryIntensityIndex = SQLite.Expression<String>(WorkoutHistoryDataBaseHelper.INTENSITY_INDEX_COLUMN)

    // Create the table if it doesn't exist
    override func createTableIfNotExists() {
        do {
            try db?.run(workoutSeriesTable.create(ifNotExists: true) { table in
                table.column(exerciseId)
                table.column(seriesOrder)
                table.column(actualReps)
                table.column(loadValue)
                table.column(intensityValue)
                
                // Foreign key constraint
                table.foreignKey(exerciseId, references: workoutHistoryTable, workoutHistoryExericseId, update: .cascade, delete: .cascade)
            })
        } catch {
            print("Error creating table: \(error)")
        }
    }

    // MARK: - Get Series Cursor
    private func getSeriesCursor(exerciseId: Int64) -> AnySequence<Row>? {
        do {
            let query = workoutSeriesTable
                .select(actualReps, loadValue, intensityValue)
                .filter(self.exerciseId == exerciseId)
                .order(seriesOrder.asc)
            return try db?.prepare(query)
        } catch {
            print("Error fetching series: \(error)")
            return nil
        }
    }

    // MARK: - Get Load Unit
    private func getLoadUnit(exerciseId: Int64) -> WeightUnit? {
        do {
            let query = workoutHistoryTable
                .select(workoutHistoryLoadUnit)
                .filter(workoutHistoryExericseId == exerciseId)
            
            if let row = try db?.pluck(query) {
                let loadUnitString = try row.get(workoutHistoryLoadUnit)
                return WeightUnit(rawValue: loadUnitString)
            }
        } catch {
            print("Error fetching load unit: \(error)")
        }
        return nil
    }
    
    private func getIntensityIndex(exerciseId: Int64) -> IntensityIndex? {
        do {
            let query = workoutHistoryTable
                .select(workoutHistoryIntensityIndex)
                .filter(workoutHistoryExericseId == exerciseId)
            
            if let row = try db?.pluck(query) {
                let intensityIndexString = try row.get(workoutHistoryIntensityIndex)
                return IntensityIndex(rawValue: intensityIndexString)
            }
        } catch {
            print("Error fetching intensity index: \(error)")
        }
        return nil
    }

    // MARK: - Get Series Data
    func getSeries(exerciseId: Int64) -> [WorkoutSeriesDraft] {
        var workoutSeries: [WorkoutSeriesDraft] = []
        
        if let cursor = getSeriesCursor(exerciseId: exerciseId) {
            for row in cursor {
                do {
                    let actualRepsValue = try row.get(self.actualReps)
                    let loadValue = try row.get(self.loadValue)
                    let intensityValue = try row.get(self.intensityValue)
                    if let loadUnit = getLoadUnit(exerciseId: exerciseId), let intensityIndex = getIntensityIndex(exerciseId: exerciseId) {
                        workoutSeries.append(WorkoutSeriesDraft(actualReps: String(actualRepsValue), actualLoad: String(loadValue), loadUnit: loadUnit, intensityIndex: intensityIndex, actualIntensity: String(intensityValue)))
                    }
                } catch {
                    print ("Error getting series \(error)")
                }
            }
        }
        return workoutSeries
    }

    // MARK: - Update Series Values
    func updateSeriesValues(exerciseId: Int64, setOrder: Int64, actualReps: Double, loadValue: Double, intensityValue: Int) {
        do {
            let query = workoutSeriesTable
                .filter(self.exerciseId == exerciseId && self.seriesOrder == setOrder)
            
            try db?.run(query.update(
                self.actualReps <- actualReps,
                self.loadValue <- loadValue,
                self.intensityValue <- intensityValue
            ))
        } catch {
            print("Error updating series values: \(error)")
        }
    }
    
    func getLastWorkoutExercisePerformance(exerciseId: Int64?) -> [WorkoutSeriesDraft] {
        var sets = [WorkoutSeriesDraft]()
        guard let exerciseId = exerciseId else {
            return sets
        }
        do {
            let query = workoutSeriesTable
                .filter(self.exerciseId == exerciseId)
            
            for row in try db!.prepare(query) {
                let actualRepsDouble = try row.get(actualReps)
                let loadValueDouble = try row.get(loadValue)
                let intensityValueInt = try row.get(intensityValue)
                
                let actualReps = actualRepsDouble.description
                let loadValue = loadValueDouble.description
                let intensityValue = intensityValueInt.description
                let loadUnit = getLoadUnit(exerciseId: exerciseId)
                let intensityIndex = getIntensityIndex(exerciseId: exerciseId)
                sets.append(WorkoutSeriesDraft(actualReps: actualReps, actualLoad: loadValue, loadUnit: loadUnit!, intensityIndex: intensityIndex!, actualIntensity: intensityValue))
            }
        } catch {
            print("Error fetching last workout performance: \(error)")
        }
        return sets
    }

    // MARK: - Get Chart Data
    func getChartData(exerciseId: Int64) -> (reps: Double, weight: Double) {
        var actualReps: Double = 0
        var loadValue: Double = 0

        do {
            // First, get the maximum value for loadValue for the given exerciseId
            let maxLoadQuery = workoutSeriesTable
                .select(self.loadValue.max)
                .filter(self.exerciseId == exerciseId)
            
            // Execute the query to get the maximum load value
            if let maxRow = try db?.pluck(maxLoadQuery),
               let maxLoadValue = maxRow[self.loadValue.max] {
                
                // Now that we have the max load value, proceed with the main query
                let query = workoutSeriesTable
                    .select(self.actualReps, self.loadValue)
                    .filter(self.exerciseId == exerciseId && self.loadValue == maxLoadValue)
                    .order(self.loadValue.desc)
                
                if let row = try db?.pluck(query) {
                    actualReps = row[self.actualReps]
                    loadValue = row[self.loadValue]
                }
            } else {
                print("No max load value found.")
            }
        } catch {
            print("Error fetching chart data: \(error)")
        }

        return (actualReps, loadValue)
    }
    
    func getExerciseSumWeight(exerciseId: Int64) -> Double {
        do {
            let sqlQuery = "SELECT SUM(\(WorkoutSeriesDataBaseHelper.LOAD_VALUE_COLUMN)) FROM \(WorkoutSeriesDataBaseHelper.TABLE_NAME) WHERE exerciseId = ?"

            if let sum = try db?.scalar(sqlQuery, exerciseId) as? Double {
                return sum
            }
        } catch {
            print("Error fetching weight sum: \(error)")
        }
        return 0.0
    }
}
