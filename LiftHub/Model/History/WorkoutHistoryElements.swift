//
//  WorkoutHistoryElements.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 09/12/2024.
//

import Foundation

@MainActor
class WorkoutHistoryElements: ObservableObject {
    @Published var history = [WorkoutHistoryElement]()
    @Published var preview: Bool
    @Published var deletedHistoryElement: WorkoutHistoryElement?
    
    private let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    
    init(preview: Bool = false) {
        self.preview = preview
        fetchTrainings()
    }
    
    func fetchTrainings() {
        if preview {
            history = WorkoutHistoryElement.sampleElements
        } else {
            history = workoutHistoryDatabaseHelper.getHistory()
        }
    }
    
    func deleteFromHistory(atOffsets indexSet: IndexSet) {
        indexSet.forEach { index in
            let historyItem = history[index]
            workoutHistoryDatabaseHelper.deleteFromHistory(date: historyItem.rawDate)
            history.removeAll(where: { $0.rawDate == historyItem.rawDate && $0.planName == historyItem.planName && $0.routineName == historyItem.routineName})
        }
        
    }
}
