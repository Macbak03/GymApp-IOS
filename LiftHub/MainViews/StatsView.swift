import SwiftUI
import Charts

// Define the data model
struct WorkoutData: Identifiable {
    let id = UUID() // Unique identifier
    let date: String // Date in String format
    let load: Double // Weight for the workout
    let reps: Double // Reps performed
}

struct StatsView: View {
    @State private var selectedExercise: String = ""
    @State private var filteredExercises: [String] = []
    @State private var trainingCount: Int = 0
    @State private var showStats: Bool = false
    //@State private var data: [WorkoutData] = [] // Store the workout data
    @State private var data = [WorkoutData]()
    @State private var selectedDataPoint: WorkoutData? = nil // Track selected point
    @State private var loading: Bool = false
    @State private var showList = false
    
    let linearGradient = LinearGradient(
        gradient: Gradient(colors: [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0)]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    let exercises = ["Squat", "Deadlift", "Bench Press", "Pull Up"]
    
    var body: some View {
        let minLoad = data.map { $0.load }.min() ?? 0 // Get minimum load from data
        let maxLoad = data.map { $0.load }.max() ?? 0 // Get maximum load from data
        let yMin = max(minLoad - 10, 0) // Start from minLoad - 10, but not below 0
        let yMax = maxLoad + (maxLoad * 0.2) // End at maxLoad + 20%
        
        VStack {
            // TextField with autocomplete
            TextField("Select exercise", text: $selectedExercise, onEditingChanged: { isEditing in
                if isEditing {
                    // When user starts editing, filter the exercise list
                    showList = true
                } else {
                    // When user stops editing, hide suggestions
                    showList = false
                }
            })
            .padding(.horizontal, 5)
            .frame(height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.textFieldOutline, lineWidth: 2)
            )
            .padding(.horizontal)
            .multilineTextAlignment(.center)
            
            // Show filtered exercises if there are any and the user is typing
            if showList {
                List {
                    ForEach(filterExercises.indices, id: \.self) { index in
                        // List item: when tapped, it sets the selected exercise and clears suggestions
                        Text(filterExercises[index])
                            .onTapGesture {
                                selectedExercise = filterExercises[index]
                                fetchData(for: filterExercises[index])
                                showList = false
                            }
                    }
                }
                .frame(maxHeight: 250) // Limit the height of the suggestion list
                .padding(.bottom, 50)
            }
            
            // Stats Buttons for filtering workouts
            //            if showStats {
            //                HStack {
            //                    Button(action: { setZoom(5) }) {
            //                        Text("Last 5").frame(maxWidth: .infinity)
            //                    }.buttonStyle(CustomButtonStyle())
            //
            //                    Button(action: { setZoom(15) }) {
            //                        Text("Last 15").frame(maxWidth: .infinity)
            //                    }.buttonStyle(CustomButtonStyle())
            //
            //                    Button(action: { setZoom(30) }) {
            //                        Text("Last 30").frame(maxWidth: .infinity)
            //                    }.buttonStyle(CustomButtonStyle())
            //
            //                    Button(action: { setZoom(CGFloat(trainingCount)) }) {
            //                        Text("All").frame(maxWidth: .infinity)
            //                    }.buttonStyle(CustomButtonStyle())
            //                }
            //                .padding(.horizontal)
            //            }
            
            // Chart and marker
            if loading {
                ProgressView().padding()
            } else {
                // Render the chart if data is available
                if !data.isEmpty {
                    Chart {
                        // Line chart with interpolation
                        ForEach(data) { item in
                            LineMark(
                                x: .value("Date", item.date),
                                y: .value("Load", item.load)
                            )
                        }
                        .interpolationMethod(.cardinal)
                        .symbol(by: .value("Date", "Load"))
                        
                        //                        // Area chart with gradient
                        //                        ForEach(data) { item in
                        //                            AreaMark(
                        //                                x: .value("Date", item.date),
                        //                                y: .value("Load", item.load)
                        //                            )
                        //                        }
                        //                        .interpolationMethod(.cardinal)
                        //                        .foregroundStyle(linearGradient)
                    }
                    .chartXScale(domain: ["01.01", "02.01", "03.01", "04.01"]) // Adjust domain to match your data
                    .chartYScale(domain: yMin...yMax)
                    .chartLegend(.hidden) // Hides the default legend
                    .chartYAxis {
                        AxisMarks(values: [100, 105, 110, 115]) { value in
                            AxisGridLine()
                            AxisTick()      // Adds ticks on the y-axis
                            if let yValue = value.as(Double.self) {
                                AxisValueLabel("\(Int(yValue))") // Shows y-axis labels as integers
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: ["01.01", "02.01", "03.01", "04.01"]) { value in
                            AxisTick() // Show a small tick for each axis value
                            if let date = value.as(String.self) {
                                AxisValueLabel(date, centered: false, anchor: .top) // Display date as string
                            }
                        }
                    }
                    .aspectRatio(1, contentMode: .fit) // Aspect ratio for responsive layout
                    .padding()
                    
                }
            }
            Spacer()
        }
        .padding(.vertical, 10)
        
    }
    
    // Simulate fetching data
    private func fetchData(for exercise: String) {
        filteredExercises = []
        loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            //Populate with dummy data for now
            data = [
                WorkoutData(date: "01.01", load: 100, reps: 5),
                WorkoutData(date: "02.01", load: 105, reps: 8),
                WorkoutData(date: "03.01", load: 110, reps: 6),
                WorkoutData(date: "04.01", load: 115, reps: 7)
            ]
            trainingCount = data.count
            showStats = true
            loading = false
        }
    }
    
    // Dummy zoom function to illustrate the button's functionality
    private func setZoom(_ zoom: CGFloat) {
        // Handle zoom (this can be expanded to adjust chart's zoom level if needed)
    }
    
    // Function to filter exercises based on the current input
    var filterExercises: [String] {
        // Filter the exercise list by matching the input text (case-insensitive)
        guard !selectedExercise.isEmpty else { return exercises }
        return exercises.filter { exercise in exercise.lowercased().contains(selectedExercise.lowercased())
        }
    }
}

// Custom button style for filter buttons
struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.gray : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

// Preview for SwiftUI
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
