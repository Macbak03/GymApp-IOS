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
    
    func getWeight() -> String {
        return UserDefaults.standard.string(forKey: weightUnitKey) ?? "kg"
    }

    func setWeight(unit: String) {
        UserDefaults.standard.set(unit, forKey: weightUnitKey)
    }
}
