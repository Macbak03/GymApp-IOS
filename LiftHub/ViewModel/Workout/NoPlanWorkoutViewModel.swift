//
//  NoPlanWorkoutViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 23/11/2024.
//

import Foundation

class NoPlanWorkoutViewModel: ObservableObject {
    @Published var workoutDraft: [WorkoutDraft] = []
    @Published var routineName: String = ""
    @Published var showNameError = false
    let planName: String
    let date: String
    let intensityIndex: IntensityIndex
    let weightUnit: WeightUnit
    
    private let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    private let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
    
    init(planName: String, date: String, intensityIndex: IntensityIndex, weightUnit: WeightUnit) {
        self.planName = planName
        self.date = date
        self.intensityIndex = intensityIndex
        self.weightUnit = weightUnit
    }
    
    func loadRoutine(isWorkoutSaved: Bool, isWorkoutEnded: Bool) {
        if !isWorkoutSaved && !isWorkoutEnded {
            initRecoveredWorkoutData()
        } else {
            workoutDraft.append(
                WorkoutDraft(
                    workoutExerciseDraft:
                        WorkoutExerciseDraft(
                            name: "",
                            pause: "0",
                            pauseUnit: TimeUnit.min,
                            series: "0",
                            reps: "0",
                            intensity: "0",
                            intensityIndex: intensityIndex,
                            pace: "0000",
                            note: ""),
                    workoutSeriesDraftList: [WorkoutSeriesDraft(
                        actualReps: "",
                        actualLoad: "",
                        loadUnit: weightUnit,
                        intensityIndex: intensityIndex,
                        actualIntensity: "")]
                ))
        }
    }
    
    private func initRecoveredWorkoutData() {
        routineName = UserDefaults.standard.string(forKey: Constants.UNFINISHED_WORKOUT_ROUTINE_NAME) ?? ""
        guard let recoveredWorkout = loadWorkoutFromFile() else {
            print("recovered workout was null in NoPlanWorkoutView")
            return
        }
        workoutDraft = recoveredWorkout
    }
    
    private func loadWorkoutFromFile() -> [WorkoutDraft]? {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("workout.json")
            
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let workoutList = try decoder.decode([WorkoutDraft].self, from: data)
                return workoutList.map {
                    WorkoutDraft(
                        workoutExerciseDraft: $0.workoutExerciseDraft,
                        workoutSeriesDraftList: $0.workoutSeriesDraftList)
                }
            } catch {
                print("Error loading workout: \(error)")
            }
        }
        return nil
    }
    
    func saveWorkoutToFile() {
        let workoutList = workoutDraft.map {
            WorkoutDraft(workoutExerciseDraft: $0.workoutExerciseDraft, workoutSeriesDraftList: $0.workoutSeriesDraftList)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(workoutList)
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentDirectory.appendingPathComponent("workout.json")
                try jsonData.write(to: fileURL)
                UserDefaults.standard.setValue(false, forKey: Constants.IS_WORKOUT_SAVED_KEY)
                UserDefaults.standard.setValue(routineName, forKey: Constants.UNFINISHED_WORKOUT_ROUTINE_NAME)
                UserDefaults.standard.setValue(date, forKey: Constants.DATE)
                print("Workout data saved at: \(fileURL)")
            }
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    func saveWorkoutToHistory(workoutStateViewModel: WorkoutStateViewModel, homeStateViewModel: HomeStateViewModel) {
        do {
            try handleWorkoutNameException()
        } catch let error as ValidationException {
            showNameError = true
            workoutStateViewModel.setToast(errorMessage: error.message)
            return
        } catch {
            workoutStateViewModel.setToast(errorMessage: "An unexpected error occured \(error)")
            return
        }
        var workout = [Workout]()
        var series = [WorkoutSeries]()
        for (index, pair) in workoutDraft.enumerated() {
            let loadUnit = pair.workoutSeriesDraftList[0].loadUnit
            let exerciseDraft = ExerciseDraft(
                name: pair.workoutExerciseDraft.name,
                pause: pair.workoutExerciseDraft.pause,
                pauseUnit: pair.workoutExerciseDraft.pauseUnit,
                load: "0",
                loadUnit: loadUnit,
                series: pair.workoutExerciseDraft.series,
                reps: pair.workoutExerciseDraft.reps,
                intensity: pair.workoutExerciseDraft.intensity,
                intensityIndex: pair.workoutExerciseDraft.intensityIndex,
                pace: pair.workoutExerciseDraft.pace,
                wasModified: false)
            for (index, setDraft) in pair.workoutSeriesDraftList.enumerated() {
                do {
                    let set = try setDraft.toWorkoutSeries(seriesCount: (index + 1))
                    series.append(set)
                } catch let error as ValidationException {
                    workoutStateViewModel.setToast(errorMessage: error.message)
                    return
                } catch {
                    workoutStateViewModel.setToast(errorMessage: "Unexpected error occured when saving workout: \(error)")
                    return
                }
            }
            do {
                let exercise = try exerciseDraft.toExercise()
                workout.append(Workout(workoutExercise: WorkoutExercise(exercise: exercise, exerciseCount: (index + 1), note: pair.workoutExerciseDraft.note), exerciseSeriesList: series))
                series.removeAll()
            } catch let error as ValidationException {
                workoutStateViewModel.setToast(errorMessage: error.message)
                return
            } catch {
                workoutStateViewModel.setToast(errorMessage:"Error in WorkoutExercise when saving workout \(error)")
                return
            }
        }
        workoutHistoryDatabaseHelper.addExercises(workout: workout, date: date, planName: planName, routineName: routineName)
        UserDefaults.standard.setValue(nil, forKey: Constants.DATE)
        UserDefaults.standard.setValue(true, forKey: Constants.IS_WORKOUT_SAVED_KEY)
        homeStateViewModel.isWorkoutEnded = true
        workoutStateViewModel.isWorkoutFinished = true
        homeStateViewModel.setToast(message: "Workout saved!")
    }
    
    private func handleWorkoutNameException() throws {
        if routineName.isEmpty {
            throw ValidationException(message: "Workout name cannot be empty")
        }
    }
    
    func validateWorkoutName(focused: Bool, workoutStateViewModel: WorkoutStateViewModel) {
        if !focused {
            do {
                try handleWorkoutNameException()
            } catch let error as ValidationException {
                showNameError = true
                workoutStateViewModel.setToast(errorMessage: error.message)
            } catch {
                workoutStateViewModel.setToast(errorMessage: "An unexpected error occured \(error)")
            }
        } else {
            showNameError = false
        }
    }
    
    func addExercise() {
        let exerciseDraft = WorkoutExerciseDraft(name: "", pause: "0", pauseUnit: TimeUnit.min, series: "0", reps: "0", intensity: "0", intensityIndex: intensityIndex, pace: "0000", note: "")
        let exerciseSetDraft = WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: weightUnit, intensityIndex: intensityIndex, actualIntensity: "")
        workoutDraft.append(WorkoutDraft(workoutExerciseDraft: exerciseDraft, workoutSeriesDraftList: [exerciseSetDraft]))
        objectWillChange.send()
    }
    
    func removeExercise(id: UUID) {
        if let index = workoutDraft.firstIndex(where: { $0.id == id }) {
                workoutDraft.remove(at: index)
        }
        objectWillChange.send()
    }
    
}
