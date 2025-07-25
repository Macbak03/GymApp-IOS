//
//  WorkoutExerciseViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 23/11/2024.
//

import Foundation

class WorkoutExerciseViewModel: ObservableObject {
    @Published var lastWorkoutComparison: [WorkoutHints] = []
    
    @Published var exerciseName = "Exercise"
    @Published var showNameError = false
    
    @Published var intensityIndexText = "Intensity"
    @Published var restValue = "val"
    @Published var restUnit = "val"
    @Published var seriesValue = "val"
    @Published var intensityValue: String? = "val"
    @Published var paceValue: String? = "val"
    @Published var volumeValue: Double = 0.0
    @Published var lastTrainingVolumeValue: Double? = nil
    @Published var volumeDifference: Double = 0.0
    
    @Published var noteHint: String = "Note"
    
    @Published var areDetailsVisible = false
    
    @Published var selectedComparingMethod = SelectedComparingMethod.lastWorkout
    
    private let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    private let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
    
    
    func initValues(workoutExerciseDraft: WorkoutExerciseDraft, workoutHints: WorkoutHints) {
        self.exerciseName = workoutExerciseDraft.name
        self.intensityIndexText = workoutExerciseDraft.intensityIndex.rawValue
        self.restValue = workoutExerciseDraft.pause
        self.restUnit = workoutExerciseDraft.pauseUnit.rawValue
        self.seriesValue = workoutExerciseDraft.series
        self.intensityValue = workoutExerciseDraft.intensity
        self.paceValue = workoutExerciseDraft.pace
        self.noteHint = workoutHints.noteHint
    }
    
    func loadLastWorkoutComparison(planName: String, routineName: String) {
        let exerciseId = workoutHistoryDatabaseHelper.getLastSessionExercisesId(planName: planName, routineName: routineName, exerciseName: exerciseName)
        let lastWorkoutData = workoutSeriesDatabaseHelper.getLastWorkoutExercisePerformance(exerciseId: exerciseId)
        if !lastWorkoutData.isEmpty {
            for lastWorkoutSeries in lastWorkoutData {
                lastWorkoutComparison.append(WorkoutHints(repsHint: lastWorkoutSeries.actualReps, weightHint: lastWorkoutSeries.actualLoad, intensityHint: lastWorkoutSeries.actualIntensity, noteHint: noteHint))
            }
        }
    }
    
    private func handleExerciseNameException(exercise: WorkoutExerciseDraft) throws {
        if exercise.name.isEmpty {
            throw ValidationException(message: "Exercise name cannot be empty")
        }
    }
    
    func validateExerciseName(focused: Bool, exercise: WorkoutExerciseDraft, stateViewModel: WorkoutStateViewModel) {
        if !focused {
            do {
                try handleExerciseNameException(exercise: exercise)
            } catch let error as ValidationException {
                showNameError = true
                stateViewModel.setToast(errorMessage: error.message)
            } catch {
                stateViewModel.setToast(errorMessage: "An unexpected error occured \(error)")
            }
        } else {
            showNameError = false
        }
    }
}

enum SelectedComparingMethod: String, CaseIterable, Codable {
    case lastWorkout = "last workout perofrmance"
    case trainingPlan = "training plan assumptions"
    
    var description: String {
        switch self {
        case .lastWorkout: return "last workout perofrmance"
        case .trainingPlan: return "training plan assumptions"
        }
    }
}
