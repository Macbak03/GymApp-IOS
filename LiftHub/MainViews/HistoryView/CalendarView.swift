//
//  CalendarView.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 09/12/2024.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    let interval: DateInterval
    @ObservedObject var historyElements: WorkoutHistoryElements
    @Binding var dateSelected: DateComponents?
    //@Binding var selectedTraining: WorkoutHistoryElement?
    @Binding var displayHistorySheet: Bool
    //@Binding var displayEditHistoryView: Bool
    @Binding var visibleMonth: DateComponents
    @Binding var trainingCount: Int
    
    func makeUIView(context: Context) -> some UIView {
        let view = UICalendarView()
        view.delegate = context.coordinator
        view.calendar = Calendar(identifier: .gregorian)
        view.availableDateRange = interval
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, historyElements: historyElements)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let calendarView = uiView as! UICalendarView
        
        // Get the initial visible month
        let currentDateComponents = calendarView.visibleDateComponents
        
        // Calculate the start and end dates for the current visible month
        guard let visibleMonthStart = Calendar.current.date(from: currentDateComponents) else { return }
        let visibleMonthEnd = Calendar.current.date(byAdding: .month, value: 1, to: visibleMonthStart)?.addingTimeInterval(-1) ?? Date()
        
        // Count trainings in the current visible month
        let countInVisibleMonth = historyElements.history.filter { element in
            guard let date = CustomDate.rawStringToDate(element.rawDate) else { return false }
            return date >= visibleMonthStart && date <= visibleMonthEnd
        }.count
        
        // Defer state updates to avoid modifying state during the update cycle
        DispatchQueue.main.async {
            visibleMonth = currentDateComponents
            trainingCount = countInVisibleMonth
        }
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        @ObservedObject var historyElements: WorkoutHistoryElements
        init(parent: CalendarView, historyElements: WorkoutHistoryElements) {
            self.parent = parent
            self.historyElements = historyElements
        }
        
        @MainActor
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let foundTrainings = historyElements.history
                .filter { CustomDate.rawStringToDate($0.rawDate)?.startOfDay == dateComponents.date?.startOfDay }
            if foundTrainings.isEmpty { return nil }
            
            return .image(UIImage(systemName: "dumbbell.fill"),
                          color: .accent,
                          size: .large)
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.dateSelected = dateComponents
            guard let dateComponents else { return }
            let foundTrainings = historyElements.history
                .filter { CustomDate.rawStringToDate($0.rawDate)?.startOfDay == dateComponents.date?.startOfDay }
            
            if foundTrainings.count > 0 {
                parent.displayHistorySheet.toggle()
            } 
//            else if foundTrainings.count == 1 {
//                if let singleTraining = foundTrainings.first {
//                    parent.selectedTraining = singleTraining
//                    parent.displayEditHistoryView = true
//                }
//            }
        }
        
        func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
            let currentDateComponents = calendarView.visibleDateComponents
            
            // Update the parent with the current visible month
            parent.visibleMonth = currentDateComponents
            
            // Calculate the start and end dates for the current visible month
            guard let visibleMonthStart = Calendar.current.date(from: currentDateComponents) else { return }
            let visibleMonthEnd = Calendar.current.date(byAdding: .month, value: 1, to: visibleMonthStart)?.addingTimeInterval(-1) ?? Date()
            
            // Count trainings in the current visible month
            let countInVisibleMonth = historyElements.history.filter { element in
                guard let date = CustomDate.rawStringToDate(element.rawDate) else { return false }
                return date >= visibleMonthStart && date <= visibleMonthEnd
            }.count
            
            // Update the training count in the parent view
            parent.trainingCount = countInVisibleMonth

        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateCopmponents: DateComponents?) -> Bool {
            return true
        }
    }
}
