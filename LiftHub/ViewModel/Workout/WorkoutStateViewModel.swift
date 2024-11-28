//
//  WorkoutStateViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 23/11/2024.
//

import Foundation

class WorkoutStateViewModel: ObservableObject {
    @Published var isWorkoutFinished = false
    @Published var showCancelAlert = false
    
    @Published var showToast = false
    @Published var toastMessage = ""
    
    @Published var isSaveClicked = false
    
    @Published var areHintsConverted = false
    
    let isWorkoutSaved = UserDefaults.standard.bool(forKey: Constants.IS_WORKOUT_SAVED_KEY)
    
    func setToast(errorMessage: String) {
        toastMessage = errorMessage
        showToast = true
    }
}
