//
//  LastWorkoutViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 29/11/2024.
//

import Foundation

class LastWorkoutViewModel: ObservableObject {    
    @Published var showToast = false
    @Published var toastMessage = ""
    
    private let historyDatabaseHelper = WorkoutHistoryDataBaseHelper()
    
    func deleteFromHistory(rawDate: String) {
        historyDatabaseHelper.deleteFromHistory(date: rawDate)
    }
}
