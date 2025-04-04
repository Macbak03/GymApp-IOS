//
//  HomeViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 23/11/2024.
//

import Foundation

class HomeStateViewModel: ObservableObject {
    let isWorkoutSaved = UserDefaults.standard.bool(forKey: Constants.IS_WORKOUT_SAVED_KEY)
    
    @Published var openStartWorkoutSheet = false
    @Published var showLastWorkout = false
    
    @Published var startWorkout = false
    @Published var startNoPlanWorkout = false
    @Published var closeStartWorkoutSheet = false
//    @Published var showToast = false
//    @Published var toastMessage = ""
    
    @Published var activeAlert: HomeAlertType? = nil
    
    
//    func setToast(message: String) {
//        showToast = true
//        toastMessage = message
//    }
    
    enum HomeAlertType: Identifiable {
        case newWorkout
        case deleteFromHistory
        
        var id: Int {
            switch self {
            case .newWorkout:
                return 1
            case .deleteFromHistory:
                return 2
            }
        }
    }
}
