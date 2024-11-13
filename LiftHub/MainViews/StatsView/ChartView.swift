//
//  ChartView.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 12/11/2024.
//

import SwiftUI
import Charts

struct ChartView: View {
    @ObservedObject var viewModel: ChartViewModel
    @Environment(\.calendar) var calendar
    @State private var chartSelection: Int?
    @State private var maxWeight: Double?
    @State private var animatedProgress: Double = 0.0
    private var areaBackground: Gradient {
        return Gradient(colors: [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0.1)])
    }
    
    
    var body: some View {
        VStack {
            Chart(viewModel.filteredChartData.indices, id: \.self) { index in
                let dataPoint = viewModel.filteredChartData[index]
                
                LineMark(
                    x: .value("Index", index),
                    y: .value("Weight", animatedProgress * dataPoint.weight.weight)
                )
                .symbol(.circle)
                .interpolationMethod(.linear)
                
                if let chartSelection {
                    ruleMarkSection(chartSelection)
                }
                
                AreaMark(
                    x: .value("Index", index),
                    y: .value("Weight", animatedProgress * dataPoint.weight.weight)
                )
                .interpolationMethod(.linear)
                .foregroundStyle(areaBackground)
            }
            .chartXAxis {
                //let indicesToShow = getLabelsToShow()
                AxisMarks(values: filterLabelsToShow()) { index in
                    if let index = index.as(Int.self), index < viewModel.filteredChartData.count {
                        let date = viewModel.filteredChartData[index].date
                        AxisValueLabel {
                            Text(date, format: .dateTime.month(.abbreviated).day(.twoDigits)) // Display formatted date as label
                        }
                    }
                }
            }
            .chartYScale(domain: 0 ... (getMaxWeight(from: viewModel.chartData) ?? 0) + 25)
            .frame(height: 300)
            .padding()
            //.chartScrollableAxes(.horizontal)
            .chartXSelection(value: $chartSelection)
            .onChange(of: chartSelection) { oldVlue, newValue in
                if let newValue = newValue {
                    chartSelection = closestDataPoint(to: newValue)
                }
            }
            .onAppear() {
                loadSelectedExercise()
                withAnimation(.easeOut(duration: 1)) {
                    animatedProgress = 1.0
                }
            }
            .onChange(of: viewModel.filteredChartData) { _, _ in
                withAnimation(.easeOut(duration: 1)) {
                    animatedProgress = 1.0
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.BackgroundColorList)
            }
            .padding()

        }
    }
    
    // if there is too much labels, it shows only 5, evenly spaced
    private func filterLabelsToShow() -> [Int] {
        let numberOfLabels = 5
        var indicesToShow: [Int]
        if viewModel.filteredChartData.count >= 15 {
            let step = max(1, viewModel.filteredChartData.count / (numberOfLabels - 1))
            indicesToShow = stride(from: 0, to: viewModel.filteredChartData.count, by: step).map { $0 }
            
            // Ensure that the last index is always included if it’s not already in the list
            if let lastIndex = viewModel.filteredChartData.indices.last, !indicesToShow.contains(lastIndex) {
                indicesToShow.append(lastIndex)
            }
        } else {
            // Show all indices if the count is less than 15
            indicesToShow = Array(viewModel.filteredChartData.indices)
        }
        return indicesToShow
    }
    
    private func getMaxWeight(from chartData: [ChartData]) -> Double? {
        return chartData.compactMap { $0.weight.weight }.max()
    }
    
    private func ruleMarkSection(_ chartSelection: Int) -> some ChartContent {
        let marker = viewModel.filteredChartData[chartSelection]
        let formattedText = formatText(marker: marker)
        
        let bubbleWidth: CGFloat = 150 // Adjust as needed to fit the text comfortably
        let chartWidth = UIScreen.main.bounds.width - 40 // Assuming padding of 20 on each side
        
        // Calculate the position of the marker in the chart
        let relativeMarkerPosition = CGFloat(chartSelection) / CGFloat(viewModel.filteredChartData.count - 1)
        let markerPositionX = relativeMarkerPosition * chartWidth
        
        // Calculate the bubble's horizontal position to keep it as centered as possible
        let bubblePositionX = min(max(markerPositionX - bubbleWidth / 2, 20), chartWidth - bubbleWidth)
        
        // Calculate the arrow offset: arrow tip should point directly to the marker
        let arrowOffset = markerPositionX - (bubblePositionX + bubbleWidth / 2)

        
        return RuleMark(x: .value("Index", chartSelection))
            .foregroundStyle(.gray.opacity(0.5))
            .annotation(
                position: .top,
                overflowResolution: .init(x: .fit, y: .disabled)
            ) {
                ZStack {
                    MessageBubbleView(text: formattedText, arrowOffset: arrowOffset)
                }
                .padding()
            }
    }
    
    private func getAxisValues(chartData: [ChartData], range: ChartValuesRange) -> [Int] {
        let totalCount = chartData.count

        switch range {
        case .last5:
            return Array(max(totalCount - 5, 0)..<totalCount)
        case .last15:
            return Array(max(totalCount - 15, 0)..<totalCount)
        case .last30:
            return Array(max(totalCount - 30, 0)..<totalCount)
        case .all:
            return Array(chartData.indices)
        }
    }
    
    private func formatText(marker: ChartData) -> String {
        let date = marker.date
        let formattedDate = CustomDate.getChartFormattedDate(savedDate: date)
        // Conditional formatting for weight and reps
        let formattedWeight: String
        if marker.weight.weight == floor(marker.weight.weight) {
            formattedWeight = "\(Int(marker.weight.weight)) \(viewModel.weightUnit.rawValue)"
        } else {
            formattedWeight = String(format: "%.2f \(viewModel.weightUnit.rawValue)", marker.weight.weight)
        }
        
        let formattedReps: String
        if marker.reps == floor(marker.reps) {
            formattedReps = "\(Int(marker.reps)) x "
        } else {
            formattedReps = String(format: "%.2f x ", marker.reps)
        }
        
        // Create the formatted text
        return "\(formattedDate)\n\(formattedReps)\(formattedWeight)"
    }
    
    private func loadSelectedExercise() {
        if let exerciseName = viewModel.selectedExerciseName {
            viewModel.chartData = ChartData.mockData(year: viewModel.selectedYear, exerciseName: exerciseName, weightUnit: viewModel.weightUnit)
            //viewModel.chartData = ChartData.generateTestData(year: viewModel.selectedYear)
            viewModel.filteredChartData = viewModel.setFilteredChartData(chartData: viewModel.chartData)
        }
    }
    
}

private extension ChartView {
    func getMarker(for date: Date) -> ChartData {
        return viewModel.filteredChartData.first(where: { calendar.isDate($0.date, equalTo: date, toGranularity: .day) }) ?? ChartData(exerciseId: 0, date: Date(), reps: 0, weight: Weight(weight: 0, unit: WeightUnit.kg))
    }
    
    func closestDataPoint(to index: Int) -> Int {
        guard !viewModel.filteredChartData.isEmpty else {
            return index
        }
        return min(max(index, 0), viewModel.filteredChartData.count - 1)
    }
    
}

