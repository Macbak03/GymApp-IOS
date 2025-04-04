//
//  UserDefaults.Utils.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//

import Foundation

class UserDefaultsUtils {
    static let shared = UserDefaultsUtils()
    private let themeKey = "theme"
    private let intensityKey = "intensity"
    private let weightUnitKey = "weightUnit"

    func getTheme() -> String {
        return UserDefaults.standard.string(forKey: themeKey) ?? "Light"
    }

    func setTheme(theme: String) {
        UserDefaults.standard.set(theme, forKey: themeKey)
    }
    
    func getIntensity() -> String {
        return UserDefaults.standard.string(forKey: intensityKey) ?? "RPE"
    }

    func setIntensity(intensity: String) {
        UserDefaults.standard.set(intensity, forKey: intensityKey)
    }
    
    func getWeightUnit() -> String {
        return UserDefaults.standard.string(forKey: weightUnitKey) ?? "kg"
    }

    func setWeight(unit: String) {
        UserDefaults.standard.set(unit, forKey: weightUnitKey)
    }
    
    func setSelectedPlan(planName: String) {
        UserDefaults.standard.set(planName, forKey: Constants.SELECTED_PLAN_NAME)
    }
    
    func getSelectedPlan() -> String {
        return UserDefaults.standard.string(forKey: Constants.SELECTED_PLAN_NAME) ?? Constants.NO_PLAN_NAME
    }
    
    func removeSelectedPlan() {
        UserDefaults.standard.removeObject(forKey: Constants.SELECTED_PLAN_NAME)
    }
    
    func setUnsavedWorkoutPlanName(planName: String) {
        UserDefaults.standard.set(planName, forKey: Constants.UNFINISHED_PLAN_NAME)
    }
    
    func getUnsavedWorkoutPlanName() -> String {
        return UserDefaults.standard.string(forKey: Constants.UNFINISHED_PLAN_NAME) ?? Constants.NO_PLAN_NAME
    }
    
    func removeUnsavedWorkoutPlanName() {
        UserDefaults.standard.removeObject(forKey: Constants.UNFINISHED_PLAN_NAME)
    }
    
    func setUnfinishedRoutineName(routineName: String) {
        UserDefaults.standard.set(routineName, forKey: Constants.UNFINISHED_WORKOUT_ROUTINE_NAME)
    }
    
    func getUnfinishedRoutineName() -> String {
        return UserDefaults.standard.string(forKey: Constants.UNFINISHED_WORKOUT_ROUTINE_NAME) ?? ""
    }
    
    func removeUnfinishedRoutineName() {
        UserDefaults.standard.removeObject(forKey: Constants.UNFINISHED_WORKOUT_ROUTINE_NAME)
    }
    
    func setDate(date: String) {
        UserDefaults.standard.set(date, forKey: Constants.DATE)
    }
    
    func getDate() -> String {
        return UserDefaults.standard.string(forKey: Constants.DATE) ?? CustomDate.getCurrentDate()
    }
    
    func removeDate() {
        UserDefaults.standard.removeObject(forKey: Constants.DATE)
    }
    
    func setWorkoutSaved(workoutSaved: Bool) {
        UserDefaults.standard.setValue(workoutSaved, forKey: Constants.IS_WORKOUT_SAVED_KEY)
    }
    
    func getWorkoutSaved() -> Bool {
        UserDefaults.standard.bool(forKey: Constants.IS_WORKOUT_SAVED_KEY)
    }
    
    func removeWorkoutSaved() {
        UserDefaults.standard.removeObject(forKey: Constants.IS_WORKOUT_SAVED_KEY)
    }
    
    func setHasWorkoutEnded(_ hasWorkoutEnded: Bool) {
        UserDefaults.standard.setValue(hasWorkoutEnded, forKey: Constants.HAS_WORKOUT_ENDED)
    }
    
    func getHasWorkoutEnded() -> Bool {
        UserDefaults.standard.bool(forKey: Constants.HAS_WORKOUT_ENDED)
    }
    
}
