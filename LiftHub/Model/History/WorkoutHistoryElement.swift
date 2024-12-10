//
//  WorkoutHistoryElement.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 16/09/2024.
//

import Foundation

struct WorkoutHistoryElement: Hashable, Identifiable {
    let id = UUID()
    var planName: String
    var routineName: String
    var formattedDate: String
    var rawDate: String
    
    init(planName: String, routineName: String, formattedDate: String, rawDate: String) {
        self.planName = planName
        self.routineName = routineName
        self.formattedDate = formattedDate
        self.rawDate = rawDate
    }
    
    static var sampleElements: [WorkoutHistoryElement] {
        return [
            WorkoutHistoryElement(planName: "plan1", routineName: "routine1", formattedDate: "2024-10-22 15:38:53", rawDate: "22.10.2024"),
            WorkoutHistoryElement(planName: "plan1", routineName: "routine2", formattedDate: "2024-10-27 15:38:53", rawDate: "27.10.2024"),
            WorkoutHistoryElement(planName: "plan1", routineName: "routine1", formattedDate: "2024-11-05 15:38:53", rawDate: "05.11.2024"),
            WorkoutHistoryElement(planName: "plan1", routineName: "routine1", formattedDate: "2024-11-12 15:38:53", rawDate: "12.11.2024")
        ]
    }
    
    var dateComponents: DateComponents {
        guard let rawDate = CustomDate.rawStringToDate(rawDate) else { return DateComponents() }
        var dateComponents = Calendar.current.dateComponents(
            [.year,
             .month,
             .day,
             .hour,
             .minute,
             .second
            ], from: rawDate)
        dateComponents.timeZone = TimeZone.current
        dateComponents.calendar = Calendar(identifier: .gregorian)
        return dateComponents
    }
}
