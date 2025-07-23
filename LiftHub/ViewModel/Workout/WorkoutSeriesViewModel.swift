//
//  WorkoutSeriesViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 23/11/2024.
//

import Foundation

class WorkoutSeriesViewModel: ObservableObject {
    let seriesCount: Int
    let position: Int
    
    @Published var repsHint: String = "Reps"
    @Published var weightHint: String = "Weight"
    @Published var intensityHint: String? = "RPE"
    @Published var intensityValue: String = ""
    
    @Published var intensityIndexText: String = "RPE"
    @Published var weightUnitText: String = "kg"
    
    @Published var showLoadError = false
    @Published var showRepsError = false
    @Published var showIntensityError = false
    
    init(seriesCount: Int, position: Int) {
        self.seriesCount = seriesCount
        self.position = position
    }
    
    func initValues(series: WorkoutSeriesDraft, hint: WorkoutHints, setCompariosn: WorkoutHints, selectedComparingMethod: SelectedComparingMethod){
        self.weightUnitText = series.loadUnit.rawValue
        self.intensityIndexText = series.intensityIndex.rawValue
        self.intensityValue = series.actualIntensity ?? ""
        
        if selectedComparingMethod == .trainingPlan {
            self.repsHint = hint.repsHint
            self.weightHint = hint.weightHint
            self.intensityHint = hint.intensityHint
        } else if selectedComparingMethod == .lastWorkout {
            self.repsHint = setCompariosn.repsHint
            self.weightHint = setCompariosn.weightHint
            self.intensityHint = setCompariosn.intensityHint
        }
    }
    
    func reloadHints(hint: WorkoutHints, setCompariosn: WorkoutHints, selectedComparingMethod: SelectedComparingMethod){
        if selectedComparingMethod == .trainingPlan {
            self.repsHint = hint.repsHint
            self.weightHint = hint.weightHint
            self.intensityHint = hint.intensityHint
        } else if selectedComparingMethod == .lastWorkout {
            self.repsHint = setCompariosn.repsHint
            self.weightHint = setCompariosn.weightHint
            self.intensityHint = setCompariosn.intensityHint
        }
    }
    
    
    private func handleRepsExcpetion(series: WorkoutSeriesDraft) throws {
        if series.actualReps.isEmpty {
            guard let _ = Double(repsHint) else {
                throw ValidationException(message: "Reps can't be in ranged value")
            }
        } else {
            guard let doubleReps = Double(series.actualReps) else {
                throw ValidationException(message: "Reps must be a number")
            }
            if doubleReps < 0 {
                throw ValidationException(message: "Reps cannot be negative")
            }
        }
    }
    
    func validateReps(focused: Bool, series: WorkoutSeriesDraft, stateViewModel: WorkoutStateViewModel) {
        if !focused {
            do {
                try handleRepsExcpetion(series: series)
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
    
    func validateLoad(focused: Bool, series: WorkoutSeriesDraft, stateViewModel: WorkoutStateViewModel) {
        if !focused {
            do {
                if !series.actualLoad.isEmpty {
                    try _ = Weight.fromStringWithUnit(series.actualLoad, unit: series.loadUnit)
                }
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
    
    private func handleEmptyIntensityException(series: WorkoutSeriesDraft) throws {
        guard let _ = Int(intensityHint!) else {
            throw ValidationException(message: "\(series.intensityIndex) can't be in ranged or floating point number value")
        }
    }
    
    func validateIntensity(focused: Bool, series: WorkoutSeriesDraft, stateViewModel: WorkoutStateViewModel) {
        if !focused {
            do {
                guard let intensity = series.actualIntensity else {
                    return
                }
                if intensity.isEmpty && intensityHint != nil {
                    try handleEmptyIntensityException(series: series)
                } else {
                    try _ = IntensityFactory.fromStringForWorkout(series.actualIntensity, index: series.intensityIndex)
                }
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
