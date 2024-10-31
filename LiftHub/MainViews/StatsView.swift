import Charts
import SwiftUI

struct StatsView: View {
    var body: some View {
        ChartView()
    }
}

struct ChartView: View {
    @Environment(\.calendar) var calendar
    @State private var markerData = ChartData.mockData(exerciseName: "Exercise1", weightUnit: WeightUnit.kg)
    @State private var chartSelection: Date?
    private var areaBackground: Gradient {
        return Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.1)])
    }
    
    
    var body: some View {
        Chart(markerData) {
            LineMark(
                x: .value("Day", $0.date, unit: .day),
                y: .value("Amount", $0.weight.weight)
            )
            .symbol(.circle)
            .interpolationMethod(.catmullRom)
            
            if let chartSelection {
                ruleMarkSection(chartSelection)
            }
            
            AreaMark(
                x: .value("Day", $0.date, unit: .day),
                y: .value("Amount", $0.weight.weight)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color.clear)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 10)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day(.twoDigits), centered: true)
            }
        }
        .chartYScale(domain: 0 ... 100)
        .frame(height: 300)
        .padding()
        //.chartScrollableAxes(.horizontal)
        .chartXSelection(value: $chartSelection)
        .onChange(of: chartSelection) { oldVlue, newValue in
            if let newValue = newValue {
                chartSelection = closestDataPoint(to: newValue)
            }
        }
    }
    
    private func ruleMarkSection(_ chartSelection: Date) -> some ChartContent {
        RuleMark(x: .value("Day", chartSelection, unit: .day))
            .foregroundStyle(.gray.opacity(0.5))
            .annotation(
                position: .top,
                overflowResolution: .init(x: .fit, y: .disabled)
            ) {
                ZStack {
                    let marker = getMarker(for: chartSelection)
                    let date = marker.date
                    let formattedDate = CustomDate.getChartFormattedDate(savedDate: date)
                    Text("\(formattedDate)\n\(String(format: "%.2f", marker.weight.weight))\(marker.weight.unit.descritpion)\n\(String(format: "%.2f", marker.reps)) reps")
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(Color.accentColor.opacity(0.2))
                }
            }
    }
    
}

private extension ChartView {
    func getMarker(for date: Date) -> ChartData {
        return markerData.first(where: { calendar.isDate($0.date, equalTo: date, toGranularity: .day) }) ?? ChartData(exerciseId: 0, date: Date(), reps: 0, weight: Weight(weight: 0, unit: WeightUnit.kg))
    }
    
    func closestDataPoint(to date: Date) -> Date {
            guard let closest = markerData.min(by: {
                abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
            }) else {
                return date // Fallback to the given date if no data is found
            }
            return closest.date
        }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}

