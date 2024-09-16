//
//  WorkoutSeriesDataBaseHelper.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 15/09/2024.
//

import Foundation
import SQLite

class WorkoutSeriesDatabaseHelper : Repository{
    static let TABLE_NAME = "workoutSeries"
    static let EXERCISE_ID_COLUMN = "exerciseID"
    static let SERIES_ORDER_COLUMN = "seriesOrder"
    static let ACTUAL_REPS_COLUMN = "actualReps"
    static let LOAD_VALUE_COLUMN = "loadValue"
    static let INTENSITY_VALUE = "intensityValue"

    // Define table and columns
    private let workoutSeriesTable = Table(TABLE_NAME)
    private let exerciseId = Expression<Int64>(EXERCISE_ID_COLUMN)
    private let seriesOrder = Expression<Int64>(SERIES_ORDER_COLUMN)
    private let actualReps = Expression<Double>(ACTUAL_REPS_COLUMN)
    private let loadValue = Expression<Double>(LOAD_VALUE_COLUMN)
    private let intensityValue = Expression<Int>(INTENSITY_VALUE)
    
    private let workoutHistoryTable = Table(WorkoutHistoryDataBaseHelper.TABLE_NAME)
    private let workoutHistoryExericseId = Expression<Int64>(WorkoutHistoryDataBaseHelper.EXERCISE_ID_COLUMN)
    private let workoutHistoryLoadUnit = Expression<String>(WorkoutHistoryDataBaseHelper.LOAD_UNIT_COLUMN)
    private let workoutHistoryIntensityIndex = Expression<String>(WorkoutHistoryDataBaseHelper.INTENSITY_INDEX_COLUMN)

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
    func updateSeriesValues(exerciseId: Int64, setOrder: Int64, actualReps: Float, loadValue: Float, intensityValue: Int) {
        do {
            let query = workoutSeriesTable
                .filter(self.exerciseId == exerciseId && self.seriesOrder == setOrder && self.intensityValue == intensityValue)
            
            try db?.run(query.update(
                self.actualReps <- Double(actualReps),
                self.loadValue <- Double(loadValue)
            ))
        } catch {
            print("Error updating series values: \(error)")
        }
    }

    // MARK: - Get Chart Data
//    func getChartData(exerciseId: Int64) -> (Float, Float) {
//        var actualReps: Float = 0
//        var loadValue: Float = 0
//
//        do {
//            let query = workoutSeriesTable
//                .select(self.actualReps, self.loadValue)
//                .filter(self.exerciseId == exerciseId && self.loadValue == workoutSeriesTable.select(self.loadValue.max))
//                .order(self.loadValue.desc)
//
//            if let row = try db?.pluck(query) {
//                actualReps = Float(row[self.actualReps])
//                loadValue = Float(row[self.loadValue])
//            }
//        } catch {
//            print("Error fetching chart data: \(error)")
//        }
//
//        return (actualReps, loadValue)
//    }
}
