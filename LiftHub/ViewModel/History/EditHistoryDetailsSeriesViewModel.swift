//
//  EditHistoryDetailsSeriesViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 22/11/2024.
//

import Foundation

class EditHistoryDetailsSeriesViewModel: ObservableObject {
    let seriesCount: Int
    let position: Int
    
    @Published var repsHint: String = "Reps"
    @Published var weightHint: String = "Weight"
    @Published var intensityHint: String = "RPE"
    
    @Published var intensityIndexText: String = "RPE"
    @Published var weightUnitText: String = "kg"
    
    @Published var intensityValue: String = ""
    @Published var exerciseType: ExerciseType
    
    @Published var showLoadError = false
    @Published var showRepsError = false
    @Published var showIntensityError = false
    
    init(seriesCount: Int, position: Int, exerciseType: ExerciseType) {
        self.seriesCount = seriesCount
        self.position = position
        self.exerciseType = exerciseType
    }
    
    func initValues(series: WorkoutSeriesDraft){
        self.weightUnitText = series.loadUnit.rawValue
        self.intensityIndexText = series.intensityIndex.rawValue
        self.intensityHint = series.intensityIndex.rawValue
        self.intensityValue = series.actualIntensity ?? ""
    }
    
    func validateReps(focused: Bool, parentViewModel: EditHistoryDetailsViewModel, series: WorkoutSeriesDraft) {
        if !focused {
            do {
                try _ = RepsFactory.fromString(series.actualReps, exerciseType: exerciseType)
            } catch let error as ValidationException {
                showRepsError = true
                parentViewModel.setToast(errorMessage: error.message)
            } catch {
                parentViewModel.setToast(errorMessage: "An unexpected error occured \(error)")
            }
        } else {
            showRepsError = false
        }
    }
    
    func validateLoad(focused: Bool, parentViewModel: EditHistoryDetailsViewModel, series: WorkoutSeriesDraft) {
        if !focused {
            do {
                try _ = Weight.fromStringWithUnit(series.actualLoad, unit: series.loadUnit)
            } catch let error as ValidationException {
                showLoadError = true
                parentViewModel.setToast(errorMessage: error.message)
            } catch {
                parentViewModel.setToast(errorMessage: "An unexpected error occured \(error)")
            }
        } else {
            showLoadError = false
        }
    }
    
    func validateIntensity(focused: Bool, parentViewModel: EditHistoryDetailsViewModel, series: WorkoutSeriesDraft) {
        if !focused {
            do {
                try _ = IntensityFactory.fromStringForWorkout(series.actualIntensity, index: series.intensityIndex)
            } catch let error as ValidationException {
                showIntensityError = true
                parentViewModel.setToast(errorMessage: error.message)
            } catch {
                parentViewModel.setToast(errorMessage: "An unexpected error occured \(error)")
            }
        } else {
            showIntensityError = false
        }
    }
}

