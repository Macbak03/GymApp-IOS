import Charts
import SwiftUI

struct StatsView: View {
    @State private var searchExercise = ""
    @State private var exercises: [String] = []
    @State private var filteredExercises: [String] = []
    @State private var selectedExercise: String? = nil
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        VStack() {
            //Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    TextField("Select exercise", text: $searchExercise)
                        .padding(10)
                        .frame(height: 35)
                        .focused($isSearchFieldFocused)
                        .onChange(of: searchExercise) { _, newText in
                            filterExercises(with: newText)
                        }
                    if !searchExercise.isEmpty {
                        Button(action: {
                            clearSearching()
                        }) {
                            Image (systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 7)
                    }
                    
                }
                .background(Color.ShadowColor)
                .cornerRadius(10)
                .padding(.leading, 20)
                .padding(.trailing, isSearchFieldFocused ? 0:20)
                
                if isSearchFieldFocused {
                    Button(action: {
                        cancelSearching()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 10)
                }
            }
            
            Spacer()
            
            ZStack {
                if let selectedExercise = selectedExercise {
                    ChartView(exerciseName: selectedExercise)
                        .id(selectedExercise)
                }
                
                
                if isSearchFieldFocused {
                    List {
                        ForEach(filteredExercises, id: \.self) { exercise in
                            Button(action: {
                                selectExercise(exercise)
                            }) {
                                Text(exercise)
                            }
                        }
                    }
                }
                
            }
            
            
            Spacer()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(false)
        }
        .onAppear() {
            loadExercises()
        }
    }
    
    private func clearSearching() {
        searchExercise.removeAll()
    }
    
    private func cancelSearching() {
        isSearchFieldFocused = false
        selectedExercise = nil
        clearSearching()
    }
    
    private func selectExercise(_ exercise: String) {
        selectedExercise = exercise
        searchExercise = exercise
        isSearchFieldFocused = false
    }
    
    private func loadExercises() {
        let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
        exercises = workoutHistoryDatabaseHelper.getExerciseNames()
        filteredExercises = exercises
    }
    
    private func filterExercises(with query: String){
        if query.isEmpty {
            filteredExercises = exercises
        } else {
            let lowercasedQuery = query.lowercased()
            filteredExercises = exercises.filter { $0.lowercased().starts(with: lowercasedQuery)}
        }
    }
}

struct ChartView: View {
    var exerciseName: String
    @Environment(\.calendar) var calendar
    @State private var chartData: [ChartData] = []
    @State private var chartSelection: Int?
    @State private var maxWeight: Double?
    private var areaBackground: Gradient {
        return Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.1)])
    }
    
    var body: some View {
        Chart(chartData.indices, id: \.self) { index in
            let dataPoint = chartData[index]
            
            LineMark(
                x: .value("Index", index),
                y: .value("Weight", dataPoint.weight.weight)
            )
            .symbol(.circle)
            .interpolationMethod(.linear)
            
            if let chartSelection {
                ruleMarkSection(chartSelection)
            }
            
            AreaMark(
                x: .value("Index", index),
                y: .value("Weight", dataPoint.weight.weight)
            )
            .interpolationMethod(.linear)
            .foregroundStyle(Color.clear)
        }
        .chartXAxis {
            AxisMarks(values: Array(chartData.indices)) { index in
                if let index = index.as(Int.self), index < chartData.count {
                    let date = chartData[index].date
                    AxisValueLabel {
                        Text(date, format: .dateTime.month(.abbreviated).day(.twoDigits)) // Display formatted date as label
                    }
                }
            }
        }
        .chartYScale(domain: 0 ... (getMaxWeight(from: chartData) ?? 0) + 25)
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
            
        }
    }
    
    private func getMaxWeight(from chartData: [ChartData]) -> Double? {
        return chartData.compactMap { $0.weight.weight }.max()
    }
    
    private func ruleMarkSection(_ chartSelection: Int) -> some ChartContent {
        let marker = chartData[chartSelection]
        let formattedText = formatText(marker: marker)
        
        let bubbleWidth: CGFloat = 150 // Adjust as needed to fit the text comfortably
        let chartWidth = UIScreen.main.bounds.width - 40 // Assuming padding of 20 on each side
        
        // Calculate the position of the marker in the chart
        let relativeMarkerPosition = CGFloat(chartSelection) / CGFloat(chartData.count - 1)
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
                    Text(formattedText)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                }
                .padding()
                .background {
                    MessageBubbleShape(arrowOffset: arrowOffset)
                        .foregroundStyle(Color.ShadowColor)
                }
            }
    }
    
    private func formatText(marker: ChartData) -> String {
        let date = marker.date
        let formattedDate = CustomDate.getChartFormattedDate(savedDate: date)
        // Conditional formatting for weight and reps
        let formattedWeight: String
        if marker.weight.weight == floor(marker.weight.weight) {
            formattedWeight = "\(Int(marker.weight.weight)) kg"
        } else {
            formattedWeight = String(format: "%.2f kg", marker.weight.weight)
        }
        
        let formattedReps: String
        if marker.reps == 1 {
            formattedReps = "1 rep"
        } else if marker.reps == floor(marker.reps) {
            formattedReps = "\(Int(marker.reps)) reps"
        } else {
            formattedReps = String(format: "%.2f reps", marker.reps)
        }
        
        // Create the formatted text
        return "\(formattedDate)\n\(formattedWeight)\n\(formattedReps)"
    }
    
    private func loadSelectedExercise() {
        chartData = ChartData.mockData(exerciseName: exerciseName, weightUnit: WeightUnit.kg)
    }
    
}

private extension ChartView {
    func getMarker(for date: Date) -> ChartData {
        return chartData.first(where: { calendar.isDate($0.date, equalTo: date, toGranularity: .day) }) ?? ChartData(exerciseId: 0, date: Date(), reps: 0, weight: Weight(weight: 0, unit: WeightUnit.kg))
    }
    
    func closestDataPoint(to index: Int) -> Int {
        guard !chartData.isEmpty else {
            return index
        }
        return min(max(index, 0), chartData.count - 1)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}

