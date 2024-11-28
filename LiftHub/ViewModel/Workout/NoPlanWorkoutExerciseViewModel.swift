//
//  NoPlanWorkoutExerciseViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 23/11/2024.
//

import Foundation

class NoPlanWorkoutExerciseViewModel: ObservableObject {
    @Published var showNameError = false
    let exerciseCount: Int
    
    init(exerciseCount: Int) {
        self.exerciseCount = exerciseCount
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
