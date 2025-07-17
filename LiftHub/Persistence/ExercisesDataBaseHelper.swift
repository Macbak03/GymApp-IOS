//
//  ExercisesDataBaseHelper.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 11/09/2024.
//

import Foundation
import SQLite

class ExercisesDataBaseHelper: Repository {
    // Define table and columns
    private let exercisesTable = Table("exercises")
    private let planId = SQLite.Expression<Int64>("PlanID")
    private let routineId = SQLite.Expression<Int64>("RoutineID")
    private let routineName = SQLite.Expression<String>("RoutineName")
    private let exerciseOrder = SQLite.Expression<Int64>("ExerciseOrder")
    private let exerciseName = SQLite.Expression<String>("ExerciseName")
    private let pauseRangeFrom = SQLite.Expression<Int>("PauseRangeFrom")
    private let pauseRangeTo = SQLite.Expression<Int>("PauseRangeTo")
    private let loadValue = SQLite.Expression<Double>("LoadValue")
    private let loadUnit = SQLite.Expression<String>("LoadUnit")
    private let repsRangeFrom = SQLite.Expression<Int>("RepsRangeFrom")
    private let repsRangeTo = SQLite.Expression<Int>("RepsRangeTo")
    private let series = SQLite.Expression<Int>("Series")
    private let intensityRangeFrom = SQLite.Expression<Int>("RPERangeFrom")
    private let intensityRangeTo = SQLite.Expression<Int>("RPERangeTo")
    private let intensityIndex = SQLite.Expression<String>("IntensityIndex")
    private let pace = SQLite.Expression<String>("Pace")
    
    private let routinesTable = Table(RoutinesDataBaseHelper.TABLE_NAME)
    private let routinesTableRoutineId = SQLite.Expression<Int64>(RoutinesDataBaseHelper.ROUTINE_ID_COLUMN)
    private let routinesTablePlanId = SQLite.Expression<Int64>(RoutinesDataBaseHelper.PLAN_ID_COLUMN)
    private let routinesTableRoutineName = SQLite.Expression<String>(RoutinesDataBaseHelper.ROUTINE_NAME_COLUMN)
    private let plansTable = Table(PlansDataBaseHelper.TABLE_NAME)
    private let plansTableId = SQLite.Expression<Int64>(PlansDataBaseHelper.ID_COLUMN)

    // Create the table if it doesn't exist
    override func createTableIfNotExists() {
        do {
            try db?.run(exercisesTable.create(ifNotExists: true) { table in
                table.column(planId)
                table.column(routineId)
                table.column(routineName)
                table.column(exerciseOrder)
                table.column(exerciseName)
                table.column(pauseRangeFrom)
                table.column(pauseRangeTo)
                table.column(loadValue)
                table.column(loadUnit)
                table.column(repsRangeFrom)
                table.column(repsRangeTo)
                table.column(series)
                table.column(intensityRangeFrom)
                table.column(intensityRangeTo)
                table.column(intensityIndex)
                table.column(pace)

                // Foreign key constraints
                table.foreignKey(routineId, references: routinesTable, routineId, update: .cascade, delete: .cascade)
                table.foreignKey(planId, references: plansTable, plansTableId, update: .cascade, delete: .cascade)
            })
        } catch {
            print("Error creating table: \(error)")
        }
    }

    // Function to add an exercise
    private func addExercise(exercise: Exercise, routineName: String, planId: Int64, routineId: Int64, exerciseCount: Int64) {
        do {
            var fromPause = 0
            var toPause = 0
            
            // Handle the pause types (ExactPause, RangePause)
            if let exactPause = exercise.pause as? ExactPause {
                fromPause = exactPause.value
                toPause = fromPause
            } else if let rangePause = exercise.pause as? RangePause {
                fromPause = rangePause.from
                toPause = rangePause.to
            }
            
            // Handle the reps types (ExactReps, RangeReps)
            var fromReps = 0
            var toReps = 0
            if let exactReps = exercise.reps as? ExactReps {
                fromReps = exactReps.value
                toReps = fromReps
            } else if let rangeReps = exercise.reps as? RangeReps {
                fromReps = rangeReps.from
                toReps = rangeReps.to
            }

            var fromIntensity: Int = 0
            var toIntensity: Int = 0
            var intensityIndexValue: String = ""
            
            // Handle the intensity types (ExactIntensity, RangeIntensity)
            if let exactIntensity = exercise.intensity as? ExactIntensity {
                fromIntensity = exactIntensity.value
                toIntensity = fromIntensity
                intensityIndexValue = exactIntensity.index.descritpion
            } else if let rangeIntensity = exercise.intensity as? RangeIntensity {
                fromIntensity = rangeIntensity.from
                toIntensity = rangeIntensity.to
                intensityIndexValue = rangeIntensity.index.rawValue
            }

            // Insert exercise data into the table
            try db?.run(exercisesTable.insert(
                self.planId <- planId,
                self.routineId <- routineId,
                self.routineName <- routineName,
                self.exerciseOrder <- exerciseCount,
                self.exerciseName <- exercise.name,
                self.pauseRangeFrom <- fromPause,
                self.pauseRangeTo <- toPause,
                self.loadValue <- exercise.load.weight,
                self.loadUnit <- exercise.load.unit.rawValue,
                self.repsRangeFrom <- fromReps,
                self.repsRangeTo <- toReps,
                self.series <- exercise.series,
                self.intensityRangeFrom <- fromIntensity,
                self.intensityRangeTo <- toIntensity,
                self.intensityIndex <- intensityIndexValue,
                self.pace <- exercise.pace.description
            ))
        } catch {
            print("Error adding exercise: \(error)")
        }
    }

    // Function to add a routine
    func addRoutine(routine: [Exercise], routineName: String, planId: Int64, originalRoutineName: String?) {
        do {
            try db?.transaction {
                if let originalRoutineName = originalRoutineName {
                    let routineId = getRoutineId(routineName: originalRoutineName, planId: planId)
                    if let routineId = routineId {
                        updateInRoutines(planId: planId, routineId: routineId, originalRoutineName: originalRoutineName, routineName: routineName)
                        deleteRoutine(planId: planId, routineId: routineId, originalRoutineName: originalRoutineName)
                        var exerciseCount: Int64 = 1
                        for exercise in routine {
                            addExercise(exercise: exercise, routineName: routineName, planId: planId, routineId: routineId, exerciseCount: exerciseCount)
                            exerciseCount += 1
                        }
                    }
                } else {
                    addToRoutines(routineName: routineName, planId: planId)
                    if let routineId = getRoutineId(routineName: routineName, planId: planId) {
                        var exerciseCount: Int64 = 1
                        for exercise in routine {
                            addExercise(exercise: exercise, routineName: routineName, planId: planId, routineId: routineId, exerciseCount: exerciseCount)
                            exerciseCount += 1
                        }
                    }
                }
            }
        } catch {
            print("Error adding routine: \(error)")
        }
    }

    // Add a routine to the routines table
    private func addToRoutines(routineName: String, planId: Int64) {
        do {
            try db?.run(routinesTable.insert(
                routinesTableRoutineName <- routineName,
                routinesTablePlanId <- planId
            ))
        } catch {
            print("Error adding to routines: \(error)")
        }
    }

    // Get the routine ID based on routine name and plan ID
    private func getRoutineId(routineName: String, planId: Int64) -> Int64? {
        do {
            let query = routinesTable
                .select(routinesTableRoutineId)
                .filter(routinesTableRoutineName == routineName && routinesTablePlanId == planId)
            
            if let row = try db?.pluck(query) {
                return row[routinesTableRoutineId]
            }
        } catch {
            print("Error fetching routine ID: \(error)")
        }
        return nil
    }

    // Update a routine
    private func updateInRoutines(planId: Int64, routineId: Int64, originalRoutineName: String, routineName: String) {
        do {
            let routineToUpdate = routinesTable
                .filter(routinesTablePlanId == planId && routinesTableRoutineId == routineId && routinesTableRoutineName == originalRoutineName)
            
            try db?.run(routineToUpdate.update(routinesTableRoutineName <- routineName))
        } catch {
            print("Error updating routine: \(error)")
        }
    }
    
    func getRoutine(routineName: String, planId: String) -> [ExerciseDraft] {
        var exercises: [ExerciseDraft] = []
        
        do {
            let query = exercisesTable
                .filter(self.routineName == routineName && self.planId == Int64(planId)!)
                .order(exerciseOrder)
            
            for exerciseRow in try db!.prepare(query) {
                let exerciseName = try exerciseRow.get(self.exerciseName)
                var pauseRangeFromInt = try exerciseRow.get(self.pauseRangeFrom)
                var pauseRangeToInt = try exerciseRow.get(self.pauseRangeTo)

                let seconds = 60
                let pauseUnit: TimeUnit
                if (pauseRangeFromInt % seconds == 0 && pauseRangeToInt % seconds == 0) {
                    pauseRangeFromInt /= seconds
                    pauseRangeToInt /= seconds
                    pauseUnit = .min
                } else {
                    pauseUnit = .s
                }

                // Determine pause type (ExactPause or RangePause)
                let pause: String
                if pauseRangeFromInt == pauseRangeToInt {
                    pause = ExactPause(value: pauseRangeFromInt, pauseUnit: pauseUnit).description
                } else {
                    pause = RangePause(from: pauseRangeFromInt, to: pauseRangeToInt, pauseUnit: pauseUnit).description
                }

                // Load and its unit
                let loadValue = try exerciseRow.get(self.loadValue)
                let loadUnit = WeightUnit(rawValue: try exerciseRow.get(self.loadUnit)) ?? .kg

                // Reps range (ExactReps or RangeReps)
                let repsRangeFrom = try exerciseRow.get(self.repsRangeFrom)
                let repsRangeTo = try exerciseRow.get(self.repsRangeTo)
                let reps: String
                if repsRangeFrom == repsRangeTo {
                    reps = ExactReps(value: repsRangeFrom).description
                } else {
                    reps = RangeReps(from: repsRangeFrom, to: repsRangeTo).description
                }

                // Series
                let series = try exerciseRow.get(self.series)

                // Intensity
                let intensityIndex = try exerciseRow.get(self.intensityIndex)
                let intensityRangeFrom = try exerciseRow.get(self.intensityRangeFrom)
                let intensityRangeTo = try exerciseRow.get(self.intensityRangeTo)
                let intensity: String
                if intensityRangeFrom == intensityRangeTo {
                    intensity = ExactIntensity(value: intensityRangeFrom, index: IntensityIndex(rawValue: intensityIndex)!).description
                } else {
                    intensity = RangeIntensity(from: intensityRangeFrom, to: intensityRangeTo, index: IntensityIndex(rawValue: intensityIndex)!).description
                }

                // Pace
                let pace = try exerciseRow.get(self.pace)

                // Create the ExerciseDraft object and add it to the list
                let exercise = ExerciseDraft(
                    name: exerciseName,
                    pause: pause,
                    pauseUnit: pauseUnit,
                    load: String(loadValue),
                    loadUnit: loadUnit,
                    series: String(series),
                    reps: reps,
                    intensity: intensity,
                    intensityIndex: IntensityIndex(rawValue: intensityIndex)!,
                    pace: pace,
                    wasModified: false
                )
                
                exercises.append(exercise)
            }
        } catch {
            print("Error fetching routine: \(error)")
        }

        return exercises
    }


    // Delete a routine
    private func deleteRoutine(planId: Int64, routineId: Int64, originalRoutineName: String?) {
        do {
            let routineToDelete = exercisesTable
                .filter(routinesTablePlanId == planId && routinesTableRoutineId == routineId && routinesTableRoutineName == originalRoutineName!)
            
            try db?.run(routineToDelete.delete())
        } catch {
            print("Error deleting routine: \(error)")
        }
    }
}
