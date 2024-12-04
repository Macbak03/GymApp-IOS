//
//  HomeViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 28/11/2024.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var workoutHistoryElement = WorkoutHistoryElement(planName: "plan", routineName: "routine", formattedDate: "date", rawDate: "rawDate")
    
    @Published var intensityIndex = IntensityIndex(rawValue: UserDefaultsUtils.shared.getIntensity())!
    @Published var weightUnit = WeightUnit(rawValue: UserDefaultsUtils.shared.getWeightUnit())!
    
    @Published var unsavedWorkoutPlanName = ""
    
    private let historyDatabaseHelper = WorkoutHistoryDataBaseHelper()
    
    func loadLastWorkout(stateViewModel: HomeStateViewModel){
        if historyDatabaseHelper.isTableNotEmpty() {
            stateViewModel.showLastWorkout = true
        } else {
            stateViewModel.showLastWorkout = false
        }
        let lastWorkout = historyDatabaseHelper.getLastWorkout()
        guard let workoutPlanName = lastWorkout[0] else {
            return
        }
        guard let workoutDate = lastWorkout[1] else {
            return
        }
        guard let workoutRoutineName = lastWorkout[2] else {
            return
        }
        workoutHistoryElement.planName = workoutPlanName
        workoutHistoryElement.rawDate = workoutDate
        workoutHistoryElement.formattedDate = CustomDate.getFormattedDate(savedDate: workoutDate)
        workoutHistoryElement.routineName = workoutRoutineName
    }
    
    func getUnsavedWorkoutPlanName() {
        unsavedWorkoutPlanName = UserDefaultsUtils.shared.getSelectedPlan()
    }
    
}
