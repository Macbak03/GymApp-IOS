//
//  NoPlanWorkoutSetViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 23/11/2024.
//

import Foundation

class NoPlanWorkoutSetViewModel: ObservableObject {
    @Published var repsHint: String = "Reps"
    @Published var weightHint: String = "Weight"
    @Published var intensityHint: String = UserDefaultsUtils.shared.getIntensity()
    
    @Published var intensityIndexText: String = UserDefaultsUtils.shared.getIntensity()
    @Published var weightUnitText: String = UserDefaultsUtils.shared.getWeightUnit()
    
    @Published var showLoadError = false
    @Published var showRepsError = false
    @Published var showIntensityError = false
    
    let seriesCount: Int
    
    init(seriesCount: Int) {
        self.seriesCount = seriesCount
    }
    
    func validateReps(focused: Bool, set: WorkoutSeriesDraft,  stateViewModel: WorkoutStateViewModel) {
        if !focused {
            do {
                try _ = RepsFactory.fromString(set.actualReps)
            } catch let error as ValidationException {
                showRepsError = true
                stateViewModel.setToast(errorMessage: error.message)
            } catch {
                stateViewModel.setToast(errorMessage: "An unexpected error occured \(error)")
            }
        } else {
            showRepsError = false
        }
    }
    
    func validateLoad(focused: Bool, set: WorkoutSeriesDraft, stateViewModel: WorkoutStateViewModel) {
        if !focused {
            do {
                try _ = Weight.fromStringWithUnit(set.actualLoad, unit: set.loadUnit)
            } catch let error as ValidationException {
                showLoadError = true
                stateViewModel.setToast(errorMessage: error.message)
            } catch {
                stateViewModel.setToast(errorMessage: "An unexpected error occured \(error)")
            }
        } else {
            showLoadError = false
        }
    }
    
    func validateIntensity(focused: Bool, set: WorkoutSeriesDraft, stateViewModel: WorkoutStateViewModel) {
        if !focused {
            do {
                try _ = IntensityFactory.fromStringForWorkout(set.actualIntensity, index: set.intensityIndex)
            } catch let error as ValidationException {
                showIntensityError = true
                stateViewModel.setToast(errorMessage: error.message)
            } catch {
                stateViewModel.setToast(errorMessage: "An unexpected error occured \(error)")
            }
        } else {
            showIntensityError = false
        }
    }
}
