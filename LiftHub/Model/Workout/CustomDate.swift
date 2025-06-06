//
//  CustomDate.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 15/09/2024.
//

import Foundation

class CustomDate {
    // Define date format patterns
    static let RAW_PATTERN = "yyyy-MM-dd HH:mm:ss"
    static let PATTERN = "dd.MM.yyyy"
    static let CHART_PATTERN = "dd MMM"
    
    // Returns the current date as a string formatted with RAW_PATTERN
    static func getCurrentDate() -> String {
        let date = Date()  // Get the current date and time
        let formatter = DateFormatter()
        formatter.dateFormat = CustomDate.RAW_PATTERN
        formatter.timeZone = TimeZone.current  // Set the time zone to the current time zone
        return formatter.string(from: date)
    }
    
    static func rawStringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = CustomDate.RAW_PATTERN
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString)
    }
    
    static func formattedStringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = CustomDate.PATTERN
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString)
    }
    
    // Converts the savedDate string into the formatted string using PATTERN
    static func getFormattedDate(savedDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = CustomDate.RAW_PATTERN
        inputFormatter.timeZone = TimeZone.current
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = CustomDate.PATTERN
        outputFormatter.timeZone = TimeZone.current
        
        if let date = inputFormatter.date(from: savedDate) {
            return outputFormatter.string(from: date)
        } else {
            return "dateError"
        }
    }
    
    // Converts the savedDate string into the formatted string using CHART_PATTERN
    static func getChartFormattedDate(savedDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = CustomDate.CHART_PATTERN
        formatter.timeZone = TimeZone.current
        return formatter.string(from: savedDate)
    }
}

