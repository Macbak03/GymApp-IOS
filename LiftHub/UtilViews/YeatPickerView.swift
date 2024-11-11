//
//  YeatPickerView.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 11/11/2024.
//

import SwiftUI

struct YearPickerView: View {
    @State private var selectedYear: Int
    private let availableYears: [Int]

    init(availableYears: [Int]) {
        self.availableYears = availableYears
        self._selectedYear = State(initialValue: availableYears.first ?? 2023)
    }

    var body: some View {
        HStack {
            // Left Arrow Button - Decrement Year
            if let previousYear = getPreviousYear() {
                Button(action: {
                    selectedYear = previousYear
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .padding()
                }
            }

            // Display Selected Year
            Text("\(selectedYear)")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            // Right Arrow Button - Increment Year
            if let nextYear = getNextYear() {
                Button(action: {
                    selectedYear = nextYear
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .padding()
                }
            }
        }
        .padding()
    }

    // Helper function to get the previous year if available
    private func getPreviousYear() -> Int? {
        guard let currentIndex = availableYears.firstIndex(of: selectedYear), currentIndex > 0 else {
            return nil
        }
        return availableYears[currentIndex - 1]
    }

    // Helper function to get the next year if available
    private func getNextYear() -> Int? {
        guard let currentIndex = availableYears.firstIndex(of: selectedYear), currentIndex < availableYears.count - 1 else {
            return nil
        }
        return availableYears[currentIndex + 1]
    }
}

