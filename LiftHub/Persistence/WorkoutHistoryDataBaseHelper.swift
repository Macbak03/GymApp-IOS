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
    private let exerciseId = SQLite.Expression<Int64>(EXERCISE_ID_COLUMN)
    private let date = SQLite.Expression<String>("date")
    private let planName = SQLite.Expression<String>("planName")
    private let routineName = SQLite.Expression<String>("routineName")
    private let exerciseOrder = SQLite.Expression<Int64>("exerciseOrder")
    private let exerciseName = SQLite.Expression<String>("exerciseName")
    private let pauseRangeFrom = SQLite.Expression<Int>("pauseRangeFrom")
    private let pauseRangeTo = SQLite.Expression<Int>("pauseRangeTo")
    private let loadUnit = SQLite.Expression<String>(LOAD_UNIT_COLUMN)
    private let repsRangeFrom = SQLite.Expression<Int>("repsRangeFrom")
    private let repsRangeTo = SQLite.Expression<Int>("repsRangeTo")
    private let series = SQLite.Expression<Int>("series")
    private let intensityRangeFrom = SQLite.Expression<Int?>("intensityRangeFrom")
    private let intensityRangeTo = SQLite.Expression<Int?>("intensityRangeTo")
    private let intensityIndex = SQLite.Expression<String>(INTENSITY_INDEX_COLUMN)
    private let pace = SQLite.Expression<String?>("pace")
    private let notes = SQLite.Expression<String>("notes")
    private let exerciseType = SQLite.Expression<String>("exerciseType")
    
    override init() {
        super.init()
        if !UserDefaultsUtils.shared.wasHistoryDatabaseMigrationPerformed() {
            migrateTable()
            addExerciseTypeColumn()
        }
    }
    
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
    
    private func migrateTable() {
        let tableName = WorkoutHistoryDataBaseHelper.TABLE_NAME
        let helperTableName = "\(tableName)_old"
        let seriesTableName = WorkoutSeriesDataBaseHelper.TABLE_NAME
        let seriesHelperTableName = "\(seriesTableName)_old"
        do {
            try db?.transaction {
                try db?.run("ALTER TABLE \(tableName) RENAME TO \(helperTableName)")
                createTableIfNotExists()
                let columns = [
                    "exerciseID", "date", "planName", "routineName", "exerciseOrder",
                    "exerciseName", "pauseRangeFrom", "pauseRangeTo", "loadUnit",
                    "repsRangeFrom", "repsRangeTo", "series",
                    "intensityRangeFrom", "intensityRangeTo", "intensityIndex", "pace", "notes"
                ].joined(separator: ", ")
                try db?.run("""
                        INSERT INTO \(tableName) (\(columns))
                        SELECT \(columns) FROM \(helperTableName)
                    """)
                
                try db?.run("ALTER TABLE \(seriesTableName) RENAME TO \(seriesHelperTableName)")
                let workoutSeriesTable = Table(seriesTableName)
                let exerciseId = SQLite.Expression<Int64>(WorkoutSeriesDataBaseHelper.EXERCISE_ID_COLUMN)
                let seriesOrder = SQLite.Expression<Int64>(WorkoutSeriesDataBaseHelper.SERIES_ORDER_COLUMN)
                let actualReps = SQLite.Expression<Double>(WorkoutSeriesDataBaseHelper.ACTUAL_REPS_COLUMN)
                let loadValue = SQLite.Expression<Double>(WorkoutSeriesDataBaseHelper.LOAD_VALUE_COLUMN)
                let intensityValue = SQLite.Expression<Int?>(WorkoutSeriesDataBaseHelper.INTENSITY_VALUE)
                try db?.run(workoutSeriesTable.create(ifNotExists: true) { table in
                    table.column(exerciseId)
                    table.column(seriesOrder)
                    table.column(actualReps)
                    table.column(loadValue)
                    table.column(intensityValue)
                    
                    // Foreign key constraint
                    table.foreignKey(exerciseId, references: workoutHistoryTable, self.exerciseId, update: .cascade, delete: .cascade)
                })
                let seriesColumns = [
                    WorkoutSeriesDataBaseHelper.EXERCISE_ID_COLUMN, WorkoutSeriesDataBaseHelper.SERIES_ORDER_COLUMN,
                    WorkoutSeriesDataBaseHelper.ACTUAL_REPS_COLUMN, WorkoutSeriesDataBaseHelper.LOAD_VALUE_COLUMN,
                    WorkoutSeriesDataBaseHelper.INTENSITY_VALUE,
                ].joined(separator: ", ")
                try db?.run("""
                            INSERT INTO \(seriesTableName) (\(seriesColumns))
                            SELECT \(seriesColumns) FROM \(seriesHelperTableName)
                        """)
                try db?.run("DROP TABLE \(seriesHelperTableName)")
                try db?.run("DROP TABLE \(helperTableName)")
                UserDefaultsUtils.shared.setHistoryDatabaseMigrationPerformed(true)
                print("History database migration completed")
            }
        } catch {
            print("History migration failed: \(error)")
        }
    }
    
    private func addExerciseTypeColumn() {
        do {
            try db?.run(workoutHistoryTable.addColumn(exerciseType, defaultValue: ExerciseType.weighted.description))
        } catch {
            print("Adding exercise type column failed: \(error)")
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
            
            var fromIntensity: Int? = nil
            var toIntensity: Int? = nil
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
                self.pace <- workoutExercise.exercise.pace?.description,
                self.notes <- workoutExercise.note,
                self.exerciseType <- workoutExercise.exercise.exerciseType.description
            ))
        } catch {
            print("Error adding exercise to history: \(error)")
        }
    }
    
    func addSeriesToHistory(series: WorkoutSeries, exerciseId: Int64) {
        do {
            let seriesTable = Table(WorkoutSeriesDataBaseHelper.TABLE_NAME)
            let exerciseIdColumn = SQLite.Expression<Int64>(WorkoutSeriesDataBaseHelper.EXERCISE_ID_COLUMN)
            let seriesOrder = SQLite.Expression<Int64>(WorkoutSeriesDataBaseHelper.SERIES_ORDER_COLUMN)
            let actualReps = SQLite.Expression<Double>(WorkoutSeriesDataBaseHelper.ACTUAL_REPS_COLUMN)
            let loadValue = SQLite.Expression<Double>(WorkoutSeriesDataBaseHelper.LOAD_VALUE_COLUMN)
            let intensityValue = SQLite.Expression<Int?>(WorkoutSeriesDataBaseHelper.INTENSITY_VALUE)
            
            try db?.run(seriesTable.insert(
                exerciseIdColumn <- exerciseId,
                seriesOrder <- Int64(series.seriesCount),
                actualReps <- series.actualReps,
                loadValue <- series.load.weight,
                intensityValue <- Int(series.actualIntensity?.description ?? "")
            ))
        } catch {
            print("Error adding series to history: \(error)")
        }
    }
    
    //MARK: Add workout exercises to history in a transaction
    func addExercises(workout: [Workout], date: String, planName: String, routineName: String) {
        do {
            try db?.transaction {
                for exercise in workout {
                    addExerciseToHistory(date: date, workoutExercise: exercise.workoutExercise, planName: planName, routineName: routineName)
                    if let lastId = getLastExerciseId() {
                        addSeries(seriesList: exercise.exerciseSeriesList, exerciseId: lastId)
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
                let loadUnit: String = try row.get(self.loadUnit)
                
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
                
                let exerciseType = ExerciseType(rawValue: try row.get(self.exerciseType)) ?? .weighted

                let workoutExercise = WorkoutExerciseDraft(
                    exerciseType: exerciseType,
                    name: exerciseName,
                    pause: pause,
                    pauseUnit: pauseUnit,
                    series: String(series),
                    reps: reps,
                    loadUnit: WeightUnit(rawValue: loadUnit)!,
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
    
    func getLastSessionExercisesId(planName: String, routineName: String, exerciseName: String) -> Int64? {
        var exerciseId: Int64? = nil
        if let lastDate = getLastTrainingSessionDate(planName: planName, routineName: routineName) {
            do {
                let query = workoutHistoryTable
                    .select(self.exerciseId)
                    .filter(self.date == lastDate && self.exerciseName == exerciseName)
                
                if let row = try db?.pluck(query) {
                    exerciseId = try row.get(self.exerciseId)
                }
            } catch {
                print("Error fetching exercises Ids: \(error)")
            }
        }
        return exerciseId
    }
    
    // MARK: - Get Exercise Names
    func getExerciseNames() -> [String] {
        var exerciseNames: [String] = []
        do {
            let selectQuery = "SELECT DISTINCT \(exerciseName) AS exerciseName FROM \(WorkoutHistoryDataBaseHelper.TABLE_NAME) ORDER BY exerciseName"
            let cursor = try db!.prepare(selectQuery)
            for row in cursor {
                if let exerciseName = row[0] as? String {
                    exerciseNames.append(exerciseName)
                }
            }
        } catch {
            print("Error fetching exercise names: \(error)")
        }
        return exerciseNames
    }
    
    func getDistinctYears(forExercise exerciseName: String) -> [Int] {
        var years: [Int] = []
        do {
            // Query to extract distinct years from the date column
            let query = workoutHistoryTable
                .select(distinct: date)
                .filter(self.exerciseName == exerciseName)
                .order(self.date.desc)
            
            
            let cursor = try db!.prepare(query)
            for row in cursor {
                let dateString = try row.get(self.date)
                if let year = extractYear(from: dateString) {
                    years.append(year)
                }
            }
        } catch {
            print("Error fetching distinct years: \(error)")
        }
        return Array(Set(years)).sorted(by: >) // Remove duplicates and sort in descending order
    }
    
    //Helper function for getDistinctYears and getExercisesToChart
    private func extractYear(from dateString: String) -> Int? {
        let components = dateString.split(separator: "-")
        if components.count > 0 {
            let yearString = String(components[0])
            return Int(yearString)
        }
        return nil
    }
    
    
    // MARK: - Get Exercises for Chart
    func getExercisesToChart(year: Int, exerciseName: String) -> [(exerciseId: Int64, date: Date)] {
        var exercises: [(Int64, Date)] = []
        do {
            let query = workoutHistoryTable
                .select(self.exerciseId, self.date)
                .filter(self.exerciseName == exerciseName)
                .order(self.date)
            
            let cursor = try db!.prepare(query)
            for row in cursor {
                let dateString = try row.get(self.date)
                if let date = CustomDate.rawStringToDate(dateString) {
                    if let extractedYear = extractYear(from: dateString), extractedYear == year {
                        let exerciseId = try row.get(self.exerciseId)
                        exercises.append((exerciseId, date))
                    }
                }
            }
        } catch {
            print("Error fetching exercises by year and name: \(error)")
        }
        return exercises
    }
    
    // MARK: - Get Load Unit
    func getWeightUnit(exerciseId: Int64) -> WeightUnit {
        do {
            let query = workoutHistoryTable
                .select(loadUnit)
                .filter(self.exerciseId == exerciseId)
            
            if let row = try db?.pluck(query) {
                return WeightUnit(rawValue:row[loadUnit]) ?? WeightUnit.kg
            }
        } catch {
            print("Error fetching load unit: \(error)")
        }
        return WeightUnit.kg
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
