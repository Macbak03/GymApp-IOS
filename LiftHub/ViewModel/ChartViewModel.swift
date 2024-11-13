//
//  ChartViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 12/11/2024.
//

import SwiftUI
import Combine

class ChartViewModel: ObservableObject {
    @Published var chartData: [ChartData] = []
    @Published var selectedRange: ChartValuesRange = .last5
    @Published var filteredChartData: [ChartData] = []
    @Published var selectedExerciseName: String? = nil
    @Published var selectedYear: Int = 0
    @Published var weightUnit: WeightUnit
    
    init() {
        let unitString = UserDefaultsUtils.shared.getWeightUnit()
        weightUnit = WeightUnit(rawValue: unitString) ?? .kg
    }
    
    func setWeightUnit() {
        let unitString = UserDefaultsUtils.shared.getWeightUnit()
        weightUnit = WeightUnit(rawValue: unitString) ?? .kg
    }
    
    func setFilteredChartData(chartData: [ChartData]) -> [ChartData] {
        self.chartData = chartData
        switch selectedRange {
        case .last5:
            return Array(chartData.suffix(5))
        case .last15:
            return Array(chartData.suffix(15))
        case .last30:
            return Array(chartData.suffix(30))
        case .all:
            return chartData
        }
    }
    

}
