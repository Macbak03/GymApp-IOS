//
//  HistoryElementViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 22/11/2024.
//

import Foundation

class HistoryElementViewModel: ObservableObject {
    @Published var historyElement: WorkoutHistoryElement
    @Published var showToast: Bool
    @Published var toastMessage: String
    let position: Int
    
    init(historyElement: WorkoutHistoryElement, position: Int, showToast: Bool = false, toastMessage: String = "") {
        self.historyElement = historyElement
        self.position = position
        self.showToast = showToast
        self.toastMessage = toastMessage
    }
}
