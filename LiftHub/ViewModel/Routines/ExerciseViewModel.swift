//
//  ExerciseViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 21/11/2024.
//

import Foundation

class ExerciseViewModel: ObservableObject {
    @Published var exerciseDraft: ExerciseDraft
    @Published var showNameError = false
    @Published var showPauseError = false
    @Published var showLoadError = false
    @Published var showRepsError = false
    @Published var showSeriesError = false
    @Published var showIntensityError = false
    @Published var showPaceError = false
    
    init(exerciseDraft: ExerciseDraft) {
        self.exerciseDraft = exerciseDraft
    }
    
    func initExercise(exerciseDraft: ExerciseDraft) {
        self.exerciseDraft = exerciseDraft
    }
    
    private func handleExerciseNameException() throws {
        if exerciseDraft.name.isEmpty {
            throw ValidationException(message: "Exercise name cannot be empty")
        }
    }
    
    func validateExerciseName(focused: Bool, viewModel: RoutineDetailsViewModel) {
        if !focused {
            do {
                try handleExerciseNameException()
            } catch let error as ValidationException {
                showNameError = true
                viewModel.setToast(message: error.message)
            } catch {
                viewModel.setToast(message: "An unexpected error occured \(error)")
            }
        } else {
            showNameError = false
        }
    }
    
    func validatePause(focused: Bool, viewModel: RoutineDetailsViewModel) {
        if !focused {
            do {
                try _ = PauseFactory.fromString(exerciseDraft.pause, unit: exerciseDraft.pauseUnit)
            } catch let error as ValidationException {
                showPauseError = true
                viewModel.setToast(message: error.message)
            } catch {
                viewModel.setToast(message: "An unexpected error occured \(error)")
            }
        } else {
            showPauseError = false
        }
    }
    
    func validateLoad(focused: Bool, viewModel: RoutineDetailsViewModel) {
        if !focused {
            do {
                try _ = Weight.fromStringWithUnit(exerciseDraft.load, unit: exerciseDraft.loadUnit)
            } catch let error as ValidationException {
                showLoadError = true
                viewModel.setToast(message: error.message)
            } catch {
                viewModel.setToast(message: "An unexpected error occured \(error)")
            }
        } else {
            showLoadError = false
        }
    }
    
    func validateReps(focused: Bool, viewModel: RoutineDetailsViewModel) {
        if !focused {
            do {
                try _ = RepsFactory.fromString(exerciseDraft.reps)
            } catch let error as ValidationException {
                showRepsError = true
                viewModel.setToast(message: error.message)
            } catch {
                viewModel.setToast(message: "An unexpected error occured \(error)")
            }
        } else {
            showRepsError = false
        }
    }
    
    private func handleSeriesException() throws {
        if exerciseDraft.series.isEmpty {
            throw ValidationException(message: "Series cannot be empty")
        }
        guard let intSeries = Int(exerciseDraft.series) else {
            throw ValidationException(message: "Series must be a number")
        }
        if intSeries > 50 {
            throw ValidationException(message: "Sorry, can't let you create this many series because the app will crash")
        }
    }
    
    func validateSeries(focused: Bool, viewModel: RoutineDetailsViewModel) {
        if !focused {
            do {
                try handleSeriesException()
            } catch let error as ValidationException {
                showSeriesError = true
                viewModel.setToast(message: error.message)
            } catch {
                viewModel.setToast(message: "An unexpected error occured \(error)")
            }
        } else {
            showSeriesError = false
        }
    }
    
    func validateIntensity(focused: Bool, viewModel: RoutineDetailsViewModel) {
        if !focused {
            do {
                try _ = IntensityFactory.fromString(exerciseDraft.intensity, index: exerciseDraft.intensityIndex)
            } catch let error as ValidationException {
                showIntensityError = true
                viewModel.setToast(message: error.message)
            } catch {
                viewModel.setToast(message: "An unexpected error occured \(error)")
            }
        } else {
            showIntensityError = false
        }
    }
    
    func validatePace(focused: Bool, viewModel: RoutineDetailsViewModel) {
        if !focused {
            do {
                try _ = ExercisePace.fromString(exerciseDraft.pace)
            } catch let error as ValidationException {
                showPaceError = true
                viewModel.setToast(message: error.message)
            } catch {
                viewModel.setToast(message: "An unexpected error occured \(error)")
            }
        } else {
            showPaceError = false
        }
    }
}
