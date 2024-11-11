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
                VStack {
                    if let selectedExercise = selectedExercise {
                        ChartSettingsView(exerciseName: selectedExercise)
                    }
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

struct ChartSettingsView: View {
    let exerciseName: String
    @State private var selectedRange: RangeType = .last5
    @State private var selectedYear: Int = 0
    @State private var years: [Int] = [2022, 2023, 2024]
    @State private var loadChart = false
    var body: some View {
        VStack {
            Picker("Years", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(year.description).tag(year)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            .onAppear() {
                selectedYear = years[1]
                //loadYears(selectedExercise: exerciseName)
                loadChart = true
            }
            
            Picker("Range", selection: $selectedRange) {
                ForEach(RangeType.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Spacer()
            
            if loadChart {
                ChartView(exerciseName: exerciseName, selectedRange: $selectedRange, selectedYear: $selectedYear)
                    .id("\(exerciseName)-\(selectedYear)")
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.BackgroundColorList)
                    }
                    .padding()
            }
            
            Spacer()
        }
    }
    
    private func loadYears(selectedExercise: String) {
        let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
        years = workoutHistoryDatabaseHelper.getDistinctYears(forExercise: selectedExercise)
        selectedYear = years[0]
    }
}

struct ChartView: View {
    let exerciseName: String
    @Binding var selectedRange: RangeType
    @Binding var selectedYear: Int
    @Environment(\.calendar) var calendar
    @State private var chartData: [ChartData] = []
    @State private var chartSelection: Int?
    @State private var maxWeight: Double?
    @State private var animatedProgress: Double = 0.0
    private var areaBackground: Gradient {
        return Gradient(colors: [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0.1)])
    }
    
    private var filteredChartData: [ChartData] {
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

    
    var body: some View {
        VStack {
            Chart(filteredChartData.indices, id: \.self) { index in
                let dataPoint = filteredChartData[index]
                
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
                    if let index = index.as(Int.self), index < filteredChartData.count {
                        let date = filteredChartData[index].date
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
                withAnimation(.easeOut(duration: 1)) {
                    animatedProgress = 1.0
                }
            }
            .onChange(of: filteredChartData) { _, _ in
                withAnimation(.easeOut(duration: 1)) {
                    animatedProgress = 1.0
                }
            }
            BottomStatsView(filteredChartData: filteredChartData)
                .id(filteredChartData.count)
        }
    }
    
    // if there is too much labels, it shows only 5, evenly spaced
    private func filterLabelsToShow() -> [Int] {
        let numberOfLabels = 5
        var indicesToShow: [Int]
        if filteredChartData.count >= 15 {
            let step = max(1, filteredChartData.count / (numberOfLabels - 1))
            indicesToShow = stride(from: 0, to: filteredChartData.count, by: step).map { $0 }
            
            // Ensure that the last index is always included if it’s not already in the list
            if let lastIndex = filteredChartData.indices.last, !indicesToShow.contains(lastIndex) {
                indicesToShow.append(lastIndex)
            }
        } else {
            // Show all indices if the count is less than 15
            indicesToShow = Array(filteredChartData.indices)
        }
        return indicesToShow
    }
    
    private func getMaxWeight(from chartData: [ChartData]) -> Double? {
        return chartData.compactMap { $0.weight.weight }.max()
    }
    
    private func ruleMarkSection(_ chartSelection: Int) -> some ChartContent {
        let marker = filteredChartData[chartSelection]
        let formattedText = formatText(marker: marker)
        
        let bubbleWidth: CGFloat = 150 // Adjust as needed to fit the text comfortably
        let chartWidth = UIScreen.main.bounds.width - 40 // Assuming padding of 20 on each side
        
        // Calculate the position of the marker in the chart
        let relativeMarkerPosition = CGFloat(chartSelection) / CGFloat(filteredChartData.count - 1)
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
    
    private func getAxisValues(chartData: [ChartData], range: RangeType) -> [Int] {
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
       // chartData = ChartData.mockData(year: selectedYear, exerciseName: exerciseName, weightUnit: WeightUnit.kg)
        chartData = ChartData.generateTestData(year: selectedYear)
    }
    
}

private extension ChartView {
    func getMarker(for date: Date) -> ChartData {
        return filteredChartData.first(where: { calendar.isDate($0.date, equalTo: date, toGranularity: .day) }) ?? ChartData(exerciseId: 0, date: Date(), reps: 0, weight: Weight(weight: 0, unit: WeightUnit.kg))
    }
    
    func closestDataPoint(to index: Int) -> Int {
        guard !chartData.isEmpty else {
            return index
        }
        return min(max(index, 0), chartData.count - 1)
    }
    
}

struct BottomStatsView: View {
    @State private var maxWeight: Double = 0.0
    @State private var minWeight: Double = 0.0
    @State private var sumWeight: Double = 0.0
    var filteredChartData: [ChartData]
    var body: some View {
        HStack {
            VStack {
                Text("min:")
                Text(minWeight.description)
            }
            
            VStack {
                Text("max:")
                Text(maxWeight.description)
            }
            
            VStack {
                Text("sum:")
                Text(sumWeight.description)
            }
        }
        .onAppear() {
            getWeightData()
        }
    }
    private func getWeightSum() -> Double {
        return filteredChartData.reduce(0.0) { sum, data in
            sum + data.weight.weight
        }
    }
    
    private func getMinWeight() -> Double {
        return filteredChartData.min(by: { $0.weight.weight < $1.weight.weight })?.weight.weight ?? 0
    }
    
    private func getMaxWeight() -> Double {
        return filteredChartData.max(by: { $0.weight.weight < $1.weight.weight })?.weight.weight ?? 0
    }
    
    private func getWeightData() {
        maxWeight = getMaxWeight()
        minWeight = getMinWeight()
        sumWeight = getWeightSum()
    }
}

enum RangeType: String, CaseIterable {
    case all = "All"
    case last30 = "last30"
    case last15 = "last 15"
    case last5 = "last 5"
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}

