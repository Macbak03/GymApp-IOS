//
//  WorkoutHistoryDataBaseHelper.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 15/09/2024.
//

import Foundation
import SQLite

class WorkoutHistoryDataBaseHelper: Repository {
    static let TABLE_NAME = "workoutHistory"
    static let EXERCISE_ID_COLUMN = "exerciseID"
    static let LOAD_UNIT_COLUMN = "loadUnit"
    static let INTENSITY_INDEX_COLUMN = "intensityIndex"
    
    // Define table and columns
    private let workoutHistoryTable = Table(TABLE_NAME)
    private let exerciseId = Expression<Int64>(EXERCISE_ID_COLUMN)
    private let date = Expression<String>("date")
    private let planName = Expression<String>("planName")
    private let routineName = Expression<String>("routineName")
    private let exerciseOrder = Expression<Int64>("exerciseOrder")
    private let exerciseName = Expression<String>("exerciseName")
    private let pauseRangeFrom = Expression<Int>("pauseRangeFrom")
    private let pauseRangeTo = Expression<Int>("pauseRangeTo")
    private let loadUnit = Expression<String>(LOAD_UNIT_COLUMN)
    private let repsRangeFrom = Expression<Int>("repsRangeFrom")
    private let repsRangeTo = Expression<Int>("repsRangeTo")
    private let series = Expression<Int>("series")
    private let intensityRangeFrom = Expression<Int>("intensityRangeFrom")
    private let intensityRangeTo = Expression<Int>("intensityRangeTo")
    private let intensityIndex = Expression<String>(INTENSITY_INDEX_COLUMN)
    private let pace = Expression<String>("pace")
    private let notes = Expression<String>("notes")
    
    // Create the table if it doesn't exist
    override func createTableIfNotExists() {
        do {
            try db?.run(workoutHistoryTable.create(ifNotExists: true) { table in
                table.column(date)
                table.column(exerciseId, primaryKey: .autoincrement)
                table.column(planName)
                table.column(routineName)
                table.column(exerciseOrder)
                table.column(exerciseName)
                table.column(pauseRangeFrom)
                table.column(pauseRangeTo)
                table.column(loadUnit)
                table.column(repsRangeFrom)
                table.column(repsRangeTo)
                table.column(series)
                table.column(intensityRangeFrom)
                table.column(intensityRangeTo)
                table.column(intensityIndex)
                table.column(pace)
                table.column(notes)
            })
        } catch {
            print("Error creating table: \(error)")
        }
    }
    
    // Function to add an exercise to the workout history
    func addExerciseToHistory(date: String, workoutExercise: WorkoutExercise, planName: String, routineName: String) {
        do {
            var fromPause = 0
            var toPause = 0
            
            // Handle pause (ExactPause, RangePause)
            if let exactPause = workoutExercise.exercise.pause as? ExactPause {
                fromPause = exactPause.value
                toPause = fromPause
            } else if let rangePause = workoutExercise.exercise.pause as? RangePause {
                fromPause = rangePause.from
                toPause = rangePause.to
            }
            
            // Handle reps (ExactReps, RangeReps)
            var fromReps = 0
            var toReps = 0
            if let exactReps = workoutExercise.exercise.reps as? ExactReps {
                fromReps = exactReps.value
                toReps = fromReps
            } else if let rangeReps = workoutExercise.exercise.reps as? RangeReps {
                fromReps = rangeReps.from
                toReps = rangeReps.to
            }
            
            var fromIntensity = 0
            var toIntensity = 0
            var intensityIndexValue = ""
            
            // Handle intensity (ExactIntensity, RangeIntensity)
            if let exactIntensity = workoutExercise.exercise.intensity as? ExactIntensity {
                fromIntensity = exactIntensity.value
                toIntensity = fromIntensity
                intensityIndexValue = exactIntensity.index.rawValue
            } else if let rangeIntensity = workoutExercise.exercise.intensity as? RangeIntensity {
                fromIntensity = rangeIntensity.from
                toIntensity = rangeIntensity.to
                intensityIndexValue = rangeIntensity.index.rawValue
            }
            
            // Insert data into the workout history table
            try db?.run(workoutHistoryTable.insert(
                self.date <- date,
                self.planName <- planName,
                self.routineName <- routineName,
                self.exerciseOrder <- Int64(workoutExercise.exerciseCount),
                self.exerciseName <- workoutExercise.exercise.name,
                self.pauseRangeFrom <- fromPause,
                self.pauseRangeTo <- toPause,
                self.loadUnit <- workoutExercise.exercise.load.unit.rawValue,
                self.repsRangeFrom <- fromReps,
                self.repsRangeTo <- toReps,
                self.series <- workoutExercise.exercise.series,
                self.intensityRangeFrom <- fromIntensity,
                self.intensityRangeTo <- toIntensity,
                self.intensityIndex <- intensityIndexValue,
                self.pace <- workoutExercise.exercise.pace.description,
                self.notes <- workoutExercise.note
            ))
        } catch {
            print("Error adding exercise to history: \(error)")
        }
    }
    
    func addSeriesToHistory(series: WorkoutSeries, exerciseId: Int64) {
        do {
            let seriesTable = Table(WorkoutSeriesDataBaseHelper.TABLE_NAME)
            let exerciseIdColumn = Expression<Int64>(WorkoutSeriesDataBaseHelper.EXERCISE_ID_COLUMN)
            let seriesOrder = Expression<Int64>(WorkoutSeriesDataBaseHelper.SERIES_ORDER_COLUMN)
            let actualReps = Expression<Double>(WorkoutSeriesDataBaseHelper.ACTUAL_REPS_COLUMN)
            let loadValue = Expression<Double>(WorkoutSeriesDataBaseHelper.LOAD_VALUE_COLUMN)
            let intensityValue = Expression<Int>(WorkoutSeriesDataBaseHelper.INTENSITY_VALUE)
            
            
            try db?.run(seriesTable.insert(
                exerciseIdColumn <- exerciseId,
                seriesOrder <- Int64(series.seriesCount),
                actualReps <- series.actualReps,
                loadValue <- series.load.weight,
                intensityValue <- Int(series.actualIntensity.description)!
            ))
        } catch {
            print("Error adding series to history: \(error)")
        }
    }
    
    //MARK: Add workout exercises to history in a transaction
    func addExercises(workout: [(workoutExercise: WorkoutExercise, exerciseSeries: [WorkoutSeries])], date: String, planName: String, routineName: String) {
        do {
            try db?.transaction {
                for exercise in workout {
                    addExerciseToHistory(date: date, workoutExercise: exercise.workoutExercise, planName: planName, routineName: routineName)
                    if let lastId = getLastExerciseId() {
                        addSeries(seriesList: exercise.exerciseSeries, exerciseId: lastId)
                    }
                }
            }
        } catch {
            print("Error adding exercises: \(error)")
        }
    }
    
    // MARK: - Add Multiple Series
    func addSeries(seriesList: [WorkoutSeries], exerciseId: Int64) {
        for series in seriesList {
            addSeriesToHistory(series: series, exerciseId: exerciseId)
        }
    }
    
    //MARK: Delete exercises from history by date
    func deleteFromHistory(date: String) {
        do {
            let query = workoutHistoryTable.filter(self.date == date)
            try db?.run(query.delete())
        } catch {
            print("Error deleting from history: \(error)")
        }
    }
    
    //MARK: Get workout history
    func getHistory() -> [WorkoutHistoryElement] {
        var workoutHistory: [WorkoutHistoryElement] = []
        
        do {
            // Use raw SQL to enforce DISTINCT and proper ordering
            let query = """
            SELECT DISTINCT planName, date, routineName FROM workoutHistory ORDER BY date DESC
            """
            
            let rows = try db!.prepare(query)
                for row in rows {
                    if let savedDate = row[1] as? String,
                       let planName = row[0] as? String,
                        let routineName = row[2] as? String {
                        let formattedDate = CustomDate.getFormattedDate(savedDate: savedDate)
                        
                        let workoutHistoryElement = WorkoutHistoryElement(
                            planName: planName,
                            routineName: routineName,
                            formattedDate: formattedDate,
                            rawDate: savedDate
                        )
                        workoutHistory.append(workoutHistoryElement)
                    }
                }
        } catch {
            print("Error retrieving history: \(error)")
        }
        
        return workoutHistory
    }
    
    
    // MARK: - Get Exercise ID by Date and Name
    func getExerciseID(date: String, exerciseName: String) -> Int64? {
        do {
            let query = workoutHistoryTable
                .select(exerciseId)
                .filter(self.date == date && self.exerciseName == exerciseName)
            
            if let row = try db?.pluck(query) {
                return row[exerciseId]
            }
        } catch {
            print("Error fetching exercise ID: \(error)")
        }
        return nil
    }
    
    // MARK: - Get Exercise IDs by Date
    func getExerciseIdsByDate(date: String) -> [Int64] {
        var exerciseIds: [Int64] = []
        do {
            let query = workoutHistoryTable
                .select(exerciseId)
                .filter(self.date == date)
            
            for row in try db!.prepare(query) {
                exerciseIds.append(row[exerciseId])
            }
        } catch {
            print("Error fetching exercise IDs: \(error)")
        }
        return exerciseIds
    }
    
    // Helper to get the last inserted exercise ID
    private func getLastExerciseId() -> Int64? {
        do {
            let query = workoutHistoryTable
                .select(exerciseId)
                .order(exerciseId.desc)
                .limit(1)
            
            if let row = try db?.pluck(query) {
                return row[exerciseId]
            }
        } catch {
            print("Error getting last exercise ID: \(error)")
        }
        return nil
    }
    
    //MARK: Function to retrieve exercises for a workout
    func getWorkoutExercises(date: String, routineName: String, planName: String) -> [WorkoutExerciseDraft] {
        var workoutExercises: [WorkoutExerciseDraft] = []
        let seconds = 60
        
        do {
            let query = workoutHistoryTable
                .filter(self.date == date && self.routineName == routineName && self.planName == planName)
                .order(exerciseOrder.asc)
            
            for row in try db!.prepare(query) {
                let exerciseName = try row.get(self.exerciseName)
                var pauseRangeFromInt = try row.get(self.pauseRangeFrom)
                var pauseRangeToInt = try row.get(self.pauseRangeTo)
                let pauseUnit: TimeUnit
                if pauseRangeFromInt % seconds == 0 && pauseRangeToInt % seconds == 0 {
                    pauseRangeFromInt /= seconds
                    pauseRangeToInt /= seconds
                    pauseUnit = .min
                } else {
                    pauseUnit = .s
                }
                
                let pause: String = if (pauseRangeFromInt == pauseRangeToInt) {
                    ExactPause(value: pauseRangeFromInt, pauseUnit: pauseUnit).description
                } else {
                    RangePause(from: pauseRangeFromInt, to: pauseRangeToInt, pauseUnit: pauseUnit).description
                }
                
                let repsRangeFrom = try row.get(self.repsRangeFrom)
                let repsRangeTo = try row.get(self.repsRangeTo)
                let reps: String = if (repsRangeFrom == repsRangeTo) {
                    ExactReps(value: repsRangeFrom).description
                } else {
                    RangeReps(from: repsRangeFrom, to: repsRangeTo).description
                }
                
                let series = try row.get(self.series)
                
                let intensityIndex = try row.get(self.intensityIndex)
                let intensityRangeFrom = try row.get(self.intensityRangeFrom)
                let intensityRangeTo = try row.get(self.intensityRangeTo)
                let intensity: String = if (intensityRangeFrom == intensityRangeTo) {
                    ExactIntensity(value: intensityRangeFrom, index: IntensityIndex(rawValue: intensityIndex)!).description
                } else {
                    RangeIntensity(from: intensityRangeFrom, to: intensityRangeTo, index: IntensityIndex(rawValue: intensityIndex)!).description
                }
                
                let pace = try row.get(self.pace)
                let note = try row.get(self.notes)
                
                let workoutExercise = WorkoutExerciseDraft(
                    name: exerciseName,
                    pause: pause,
                    pauseUnit: pauseUnit,
                    series: String(series),
                    reps: reps,
                    intensity: intensity,
                    intensityIndex: IntensityIndex(rawValue: intensityIndex)!,
                    pace: pace,
                    note: note
                )
                workoutExercises.append(workoutExercise)
            }
        } catch {
            print("Error fetching workout exercises: \(error)")
        }
        
        return workoutExercises
    }
    
    
    // MARK: - Check if Table is Not Empty
    func isTableNotEmpty() -> Bool {
        do {
            let query = "SELECT COUNT(*) FROM workoutHistory"
            if let count = try db?.scalar(query) as? Int64 {
                return count > 0
            }
        } catch {
            print("Error checking if table is empty: \(error)")
        }
        return false
    }
    
    // MARK: - Get Last Workout
    func getLastWorkout() -> [String?] {
        var planName: String? = nil
        var date: String? = nil
        var routineName: String? = nil
        
        do {
            let query = workoutHistoryTable
                .select(self.planName, self.date, self.routineName)
                .order(self.date.desc)
                .limit(1)
            
            if let row = try db?.pluck(query) {
                planName = try row.get(self.planName)
                date = try row.get(self.date)
                routineName = try row.get(self.routineName)
            }
        } catch {
            print("Error getting last workout: \(error)")
        }
        
        return [planName, date, routineName]
    }
    
    // MARK: - Get Last Training Session Date
    func getLastTrainingSessionDate(planName: String, routineName: String) -> String? {
        var date: String? = nil
        do {
            let query = workoutHistoryTable
                .select(self.date)
                .filter(self.planName == planName && self.routineName == routineName)
                .order(self.date.desc)
                .limit(1)
            
            if let row = try db?.pluck(query) {
                date = try row.get(self.date)
            }
        } catch {
            print("Error getting last training session date: \(error)")
        }
        return date
    }
    
    // MARK: - Get Last Training Notes
    func getLastTrainingNotes(planName: String, routineName: String) -> [String] {
        var notesList: [String] = []
        if let lastDate = getLastTrainingSessionDate(planName: planName, routineName: routineName) {
            do {
                let query = workoutHistoryTable
                    .select(notes)
                    .filter(self.date == lastDate)
                
                for row in try db!.prepare(query) {
                    let note = try row.get(notes)
                    notesList.append(note)
                }
            } catch {
                print("Error fetching notes: \(error)")
            }
        }
        return notesList
    }
    
    // MARK: - Get Exercise Names
    func getExerciseNames() -> [String] {
        var exerciseNames: [String] = []
        do {
            let selectQuery = "SELECT DISTINCT LOWER\(self.exerciseName) AS exercise_name FROM \(self.workoutHistoryTable) ORDER BY exercise_name"
            let cursor = try db!.prepare(selectQuery)
            for row in cursor {
                if let exerciseName = row[5] as? String {
                    exerciseNames.append(exerciseName)
                }
            }
        } catch {
            print("Error fetching exercise names: \(error)")
        }
        return exerciseNames
    }
    
    
    //    // MARK: - Get Exercises for Chart
    //    func getExercisesToChart(exerciseName: String) -> (exerciseIds: [Int64], dates: [String]) {
    //        var exerciseIds: [Int64] = []
    //        var dates: [String] = []
    //        let customDate = CustomDate()
    //
    //        do {
    //            let query = workoutHistoryTable
    //                .select(exerciseId, self.date)
    //                .filter(self.exerciseName.lowercaseString == exerciseName.lowercased())
    //
    //            for row in try db!.prepare(query) {
    //                exerciseIds.append(row[exerciseId])
    //                let formattedDate = customDate.getChartFormattedDate(row[self.date])
    //                dates.append(formattedDate)
    //            }
    //        } catch {
    //            print("Error fetching exercises for chart: \(error)")
    //        }
    //
    //        return (exerciseIds, dates)
    //    }
    
    // MARK: - Get Load Unit
    func getLoadUnit(exerciseId: Int64) -> String? {
        do {
            let query = workoutHistoryTable
                .select(loadUnit)
                .filter(self.exerciseId == exerciseId)
            
            if let row = try db?.pluck(query) {
                return row[loadUnit]
            }
        } catch {
            print("Error fetching load unit: \(error)")
        }
        return nil
    }
    
    // MARK: - Update Plan Names
    func updatePlanNames(oldName: String, newName: String) {
        do {
            let query = workoutHistoryTable
                .filter(self.planName == oldName)
            
            try db?.run(query.update(self.planName <- newName))
        } catch {
            print("Error updating plan names: \(error)")
        }
    }
    
    // MARK: - Update Notes
    func updateNotes(date: String, exerciseId: Int64, newNote: String) {
        do {
            let query = workoutHistoryTable
                .filter(self.date == date && self.exerciseId == exerciseId)
            
            try db?.run(query.update(self.notes <- newNote))
        } catch {
            print("Error updating notes: \(error)")
        }
    }
    
    func checkForeignKeysEnabled() {
        do {
            if let result = try db?.scalar("PRAGMA foreign_keys") as? Int64 {
                print("Foreign keys status: \(result == 1 ? "Enabled" : "Disabled")")
            }
        } catch {
            print("Error checking foreign keys status: \(error)")
        }
    }
}
