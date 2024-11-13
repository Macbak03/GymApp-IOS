//
//  BottomStatsView.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 12/11/2024.
//

import SwiftUI

struct BottomStatsView: View {
    @State private var maxWeight: Double = 0.0
    @State private var minWeight: Double = 0.0
    @State private var sumWeight: Double = 0.0
    @ObservedObject var viewModel: ChartViewModel
    
    var textSize: CGFloat = 12
    var valueSize: CGFloat = 18
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("MINIMUM")
                        .font(.system(size: textSize))
                        .foregroundStyle(Color.textColorSecondary)
                    Text("\(minWeight)\(viewModel.weightUnit)")
                        .font(.system(size: valueSize))
                        .foregroundStyle(Color.accentColor)
                        .contentTransition(.numericText())
                    Text("lifted")
                        .font(.system(size: textSize))
                        .foregroundStyle(Color.accentColor)
                }
                .frame(maxWidth: .infinity)
                
                
                VStack {
                    Text("IN TOTAL")
                        .font(.system(size: textSize))
                        .foregroundStyle(Color.textColorSecondary)
                    Text("\(sumWeight)\(viewModel.weightUnit)")
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
                    Text("\(maxWeight)\(viewModel.weightUnit)")
                        .font(.system(size: valueSize))
                        .foregroundStyle(Color.accentColor)
                        .contentTransition(.numericText())
                    Text("lifted")
                        .font(.system(size: textSize))
                        .foregroundStyle(Color.accentColor)
                }
                .frame(maxWidth: .infinity)
                
            }
        }
        .onAppear() {
            getWeightData()
        }
    }
    
    private func getWeightSum() -> Double {
        return viewModel.filteredChartData.reduce(0.0) { sum, data in
            sum + data.weight.weight
        }
    }
    
    private func getMinWeight() -> Double {
        return viewModel.filteredChartData.min(by: { $0.weight.weight < $1.weight.weight })?.weight.weight ?? 0
    }
    
    private func getMaxWeight() -> Double {
        return viewModel.filteredChartData.max(by: { $0.weight.weight < $1.weight.weight })?.weight.weight ?? 0
    }
    
    private func getWeightData() {
        withAnimation {
            maxWeight = getMaxWeight()
            minWeight = getMinWeight()
            sumWeight = getWeightSum()
        }
    }
}

struct BottomStatsView_Previews: PreviewProvider {
    static var previews: some View {
        BottomStatsView(viewModel: ChartViewModel())
    }
}
