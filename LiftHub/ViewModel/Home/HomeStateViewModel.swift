//
//  HomeViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 23/11/2024.
//

import Foundation

class HomeStateViewModel: ObservableObject {
    var isWorkoutSaved = UserDefaults.standard.bool(forKey: Constants.IS_WORKOUT_SAVED_KEY)
    
    @Published var openStartWorkoutSheet = false

    
    @Published var startWorkout = false
    @Published var startNoPlanWorkout = false
    @Published var closeStartWorkoutSheet = false
    @Published var isWorkoutEnded = true
    
    @Published var showToast = false
    @Published var toastMessage = ""
}
