import Charts
import SwiftUI

struct StatsView: View {
    @StateObject var viewModel = ChartViewModel()
    @State private var searchExercise = ""
    @State private var exercises: [String] = []
    @State private var filteredExercises: [String] = []
    
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
                    if viewModel.selectedExerciseName != nil {
                        ChartSettingsView(viewModel: viewModel)
                            .onAppear() {
                                viewModel.setWeightUnit()
                            }
                    }
                }
                
                
                if isSearchFieldFocused {
                    List {
                        if !filteredExercises.isEmpty {
                            ForEach(filteredExercises, id: \.self) { exercise in
                                Button(action: {
                                    selectExercise(exercise)
                                }) {
                                    Text(exercise)
                                }
                            }
                        } else {
                            Text("No exercises avaliable")
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
            viewModel.setWeightUnit()
        }
    }
    
    
    private func clearSearching() {
        searchExercise.removeAll()
    }
    
    private func cancelSearching() {
        isSearchFieldFocused = false
        viewModel.selectedExerciseName = nil
        clearSearching()
    }
    
    private func selectExercise(_ exercise: String) {
        viewModel.selectedExerciseName = exercise
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
    @ObservedObject var viewModel: ChartViewModel
    @State private var years: [Int] = []
    @State private var loadChart = false
    
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            ScrollView {
                VStack {
                    Menu {
                        Picker(selection: $viewModel.selectedYear) {
                            ForEach(years, id: \.self) { year in
                                Text(year.description).tag(year)
                            }
                        } label: {}
                    } label: {
                        Text(viewModel.selectedYear.description)
                            .font(.system(size: 20))
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .padding(isSmallScreen(for: screenWidth) ? 0:15)
                    .onAppear() {
                        if let selectedExercise = viewModel.selectedExerciseName {
                            loadYears(selectedExercise: selectedExercise)
                        }
                        viewModel.selectedYear = years[0]
                        loadChart = true
                    }
                    
                    
                    Picker("Range", selection: $viewModel.selectedRange) {
                        ForEach(ChartValuesRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    
                    Spacer()
                    
                    if loadChart {
                        ChartView(viewModel: viewModel)
                            .id("\(String(describing: viewModel.selectedExerciseName))-\(viewModel.selectedYear)-\(viewModel.selectedRange)")
                            .padding(.top, isSmallScreen(for: screenWidth) ? 30 : 50)
                    }
                    
                    BottomStatsView(viewModel: viewModel)
                        .id("\(viewModel.filteredChartData.count)-\(viewModel.selectedRange)- \(viewModel.weightUnit)")
                        .padding(.bottom, isSmallScreen(for: screenWidth) ? 50 : 0)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func loadYears(selectedExercise: String) {
        let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
        years = workoutHistoryDatabaseHelper.getDistinctYears(forExercise: selectedExercise)
        if !years.isEmpty {
            viewModel.selectedYear = years[0]
        } else {
            print("Error getting years in loadYears")
            let currentYear = Calendar.current.component(.year, from: Date())
            years.append(currentYear)
        }
    }
    
    private func isSmallScreen(for screenWidth: CGFloat) -> Bool {
        // Adjust spacing to be smaller for smaller screen sizes
        if screenWidth < 380 {
            return true
        } else {
            return false
        }
    }
}


struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}

