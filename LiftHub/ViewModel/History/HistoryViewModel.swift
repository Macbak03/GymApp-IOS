//
//  HistoryViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 21/11/2024.
//

import Foundation

class HistoryViewModel: ObservableObject {
    @Published var history: [WorkoutHistoryElement] = []
    @Published var filteredHistory: [WorkoutHistoryElement] = []
    @Published var showToast = false
    @Published var toastMessage = ""
    
    private let historyDatabaseHelper = WorkoutHistoryDataBaseHelper()
    
    func loadHistory() {
        history = historyDatabaseHelper.getHistory()
        filteredHistory = history
    }
    
    func deleteFromHistory(historyItem: WorkoutHistoryElement) {
        historyDatabaseHelper.deleteFromHistory(date: historyItem.rawDate)
        filteredHistory.removeAll(where: { $0.rawDate == historyItem.rawDate && $0.planName == historyItem.planName && $0.routineName == historyItem.routineName})
        history.removeAll(where: { $0.rawDate == historyItem.rawDate && $0.planName == historyItem.planName && $0.routineName == historyItem.routineName})
    }
}
