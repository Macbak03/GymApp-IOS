//
//  BottomStatsView.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 12/11/2024.
//

import SwiftUI

enum ChevronDirectionClicked: Int {
    case left = 1
    case right = 2
    case none = 0
}

struct BottomStatsView: View {
    @State private var maxWeight: Double = 0.0
    @State private var maxWeightReps: Double = 0.0
    @State private var minWeight: Double = 0.0
    @State private var minWeightReps: Double = 0.0
    @State private var sumWeight: Double = 0.0
    @State private var oneRepMax: Double = 0.0
    @State private var last5MaxWeightReps: Double = 0.0
    @State private var showSecondSectionHelper: Bool = true
    @State private var chevronDirectionClicked: ChevronDirectionClicked = .none
    @State private var firstSectionSlideDirection: Edge = .leading
    @State private var secondSectionSlideDirection: Edge = .leading
    @ObservedObject var viewModel: ChartViewModel
    
    var textSize: CGFloat = 12
    var valueSize: CGFloat = 18
    var body: some View {
        HStack {
            Button(action: {
                chevronDirectionClicked = .left
                showSecondSectionHelper.toggle()
                withAnimation(.easeIn(duration: 0.2)) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        viewModel.showSecondSection.toggle()
                    }
                    
                }
            }) {
                Image(systemName: "chevron.left")
            }
            .padding()
            
            ZStack {
                if !viewModel.showSecondSection {
                    HStack {
                        VStack {
                            Text("MINIMUM")
                                .font(.system(size: textSize))
                                .foregroundStyle(Color.textColorSecondary)
                            Text(formatMinWeight())
                                .font(.system(size: valueSize))
                                .foregroundStyle(Color.accentColor)
                                .contentTransition(.numericText())
                            Text("for \(formatMinWeightReps())")
                                .font(.system(size: textSize))
                                .foregroundStyle(Color.accentColor)
                        }
                        .frame(maxWidth: .infinity)
                        
                        
                        VStack {
                            Text("IN TOTAL")
                                .font(.system(size: textSize))
                                .foregroundStyle(Color.textColorSecondary)
                            Text(formatTotalWeight())
                                .font(.system(size: valueSize))
                                .foregroundStyle(Color.accentColor)
                                .contentTransition(.numericText())
                            Text("lifted")
                                .font(.system(size: textSize))
                                .foregroundStyle(Color.accentColor)
                        }
                        .frame(maxWidth: .infinity)
                        
                        
                        VStack {
                            Text("MAXIMUM")
                                .font(.system(size: textSize))
                                .foregroundStyle(Color.textColorSecondary)
                            Text(formatMaxWeight())
                                .font(.system(size: valueSize))
                                .foregroundStyle(Color.accentColor)
                                .contentTransition(.numericText())
                            Text("for \(formatMaxWeightReps())")
                                .font(.system(size: textSize))
                                .foregroundStyle(Color.accentColor)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .transition(.move(edge: firstSectionSlideDirection))
                } else {
                    HStack {
                        VStack {
                            Text("Calculated")
                                .font(.system(size: textSize))
                                .foregroundStyle(Color.textColorSecondary)
                            Text("ONE REP MAX")
                                .font(.system(size: textSize))
                                .foregroundStyle(Color.accentColor)
                            Text("\(oneRepMax)\(viewModel.weightUnit)")
                                .font(.system(size: valueSize))
                                .foregroundStyle(Color.accentColor)
                                .contentTransition(.numericText())
                            Text("Based on last 5 trainings")
                                .font(.system(size: textSize))
                                .foregroundStyle(Color.textColorSecondary)
                            
                        }
                        
                        .frame(maxWidth: .infinity)
                    }
                    .transition(.move(edge: secondSectionSlideDirection))
                }
            }
            .animation(.easeIn(duration: 0.2), value: viewModel.showSecondSection)
            .onChange(of: chevronDirectionClicked) { _, _ in
                manageTransitionDirection()
            }
            .onChange(of: showSecondSectionHelper) { _, _ in
                manageTransitionDirection()
            }
            
            Button(action: {
                chevronDirectionClicked = .right
                showSecondSectionHelper.toggle()
                withAnimation(.easeIn(duration: 0.2)) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        viewModel.showSecondSection.toggle()
                    }
                    
                }
            }) {
                Image(systemName: "chevron.right")
            }
            .padding()
            
        }
        .onAppear() {
            getWeightData()
            showSecondSectionHelper = viewModel.showSecondSection
            firstSectionSlideDirection = viewModel.showSecondSection ? .leading : .trailing
            secondSectionSlideDirection = viewModel.showSecondSection ? .trailing : .leading
        }
        .frame(height: 70)
    }
    
    private func getWeightSum() -> Double {
        return viewModel.filteredChartData.reduce(0.0) { sum, data in
            sum + data.sumWeight
        }
    }
    
    private func getMinWeightWithReps() -> (minWeight: Double, reps: Double) {
        let min =  viewModel.filteredChartData.min {
            if $0.weight.weight == $1.weight.weight {
                return $0.reps < $1.reps // When weights are the same, choose the one with fewer reps
            } else {
                return $0.weight.weight < $1.weight.weight // Otherwise, compare by weight
            }
        }
        return (min?.weight.weight ?? 0.0, min?.reps ?? 0.0)
    }
    
    private func getMaxWeightWithReps() -> (maxWeight: Double, reps: Double) {
        let max =  viewModel.filteredChartData.max {
            if $0.weight.weight == $1.weight.weight {
                return $0.reps < $1.reps
            } else {
                return $0.weight.weight < $1.weight.weight
            }
        }
        return (max?.weight.weight ?? 0.0, max?.reps ?? 0.0)
    }
    
    private func calculateOneRepMax() -> Double {
        let last5Max = viewModel.chartData.suffix(5).max {
            if $0.weight.weight == $1.weight.weight {
                return $0.reps < $1.reps
            } else {
                return $0.weight.weight < $1.weight.weight
            }
        }
        return roundToTwoDecimals((last5Max?.weight.weight ?? 0.0) / (1.0278 - 0.0278 * (last5Max?.reps ?? 0.0))) // Based on Brzycki formula
    }
    
    private func getWeightData() {
        withAnimation {
            maxWeight = getMaxWeightWithReps().maxWeight
            maxWeightReps = getMaxWeightWithReps().reps
            minWeight = getMinWeightWithReps().minWeight
            minWeightReps = getMinWeightWithReps().reps
            sumWeight = getWeightSum()
            oneRepMax = calculateOneRepMax()
        }
    }
    
    private func formatMaxWeight() -> String {
        let roundedMaxWeight = roundToTwoDecimals(maxWeight)
        return "\(formatNumber(roundedMaxWeight))\(viewModel.weightUnit)"
    }
    
    private func formatMaxWeightReps() -> String {
        let formattedNumber = formatNumber(maxWeightReps)
        if maxWeightReps > 2 {
            return "\(formattedNumber) reps"
        } else {
            return "\(formattedNumber) rep"
        }
    }
    
    private func formatMinWeight() -> String {
        let roundedMinWeight = roundToTwoDecimals(minWeight)
        return "\(formatNumber(roundedMinWeight))\(viewModel.weightUnit)"
    }
    
    private func formatMinWeightReps() -> String {
        let formattedNumber = formatNumber(minWeightReps)
        if minWeightReps > 2 {
            return "\(formattedNumber) reps"
        } else {
            return "\(formattedNumber) rep"
        }
    }
    
    private func formatTotalWeight() -> String {
        let roundedTotalWeight = roundToTwoDecimals(sumWeight)
        return "\(formatNumber(roundedTotalWeight))\(viewModel.weightUnit)"
    }
    
    private func roundToTwoDecimals(_ value: Double) -> Double {
        return Double(round(100 * value) / 100)
    }
    
    // Helper function to format number with variable decimal places
    private func formatNumber(_ value: Double) -> String {
        if value == floor(value) {
            // No decimal places needed if the value is a whole number
            return String(format: "%.0f", value)
        } else if value * 10 == floor(value * 10) {
            // One decimal place if value has exactly one decimal point
            return String(format: "%.1f", value)
        } else {
            // Two decimal places if value has more than one decimal point
            return String(format: "%.2f", value)
        }
    }
    
    private func manageTransitionDirection() {
        if chevronDirectionClicked == .left {
            firstSectionSlideDirection = showSecondSectionHelper ? .trailing : .leading
            secondSectionSlideDirection = showSecondSectionHelper ? .leading : .trailing
        }
        if chevronDirectionClicked == .right {
            firstSectionSlideDirection = showSecondSectionHelper ? .leading : .trailing
            secondSectionSlideDirection = showSecondSectionHelper ? .trailing : .leading
        }
    }
}

struct BottomStatsView_Previews: PreviewProvider {
    static var previews: some View {
        BottomStatsView(viewModel: ChartViewModel())
    }
}
