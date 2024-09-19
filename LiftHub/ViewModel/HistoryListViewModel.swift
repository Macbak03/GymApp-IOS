//
//  HistoryListViewModel.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 19/09/2024.
//

import Foundation
import SwiftUI

class HistoryListViewModel: ObservableObject {
    @Published var history = [WorkoutHistoryElement]()
    @Published var searchText: String = ""
    
    init() {
        let workoutHistoryDatabaseHelper =  WorkoutHistoryDataBaseHelper()
        history = workoutHistoryDatabaseHelper.getHistory()
    }
    
    var searchResults: [WorkoutHistoryElement] {
        guard !searchText.isEmpty else { return history }
        let lowercasedQuery = searchText.lowercased()
        return history.filter { historyItem in
            historyItem.planName.lowercased().contains(lowercasedQuery) ||
            historyItem.routineName.lowercased().contains(lowercasedQuery) ||
            historyItem.formattedDate.lowercased().contains(lowercasedQuery)
        }
    }
    
    func updateHistory(newHistory: [WorkoutHistoryElement]) {
        history = newHistory
    }
}
