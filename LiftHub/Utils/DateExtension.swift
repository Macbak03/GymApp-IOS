//
//  DateExtension.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 09/12/2024.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
