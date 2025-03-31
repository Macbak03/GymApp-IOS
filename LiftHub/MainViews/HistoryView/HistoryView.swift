//
//  HistoryView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 16/09/2024.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var searchText = ""
    @StateObject var workoutHistoryElements = WorkoutHistoryElements()
    @State private var dateSelected: DateComponents?
    @State private var displayTrainings = false
    //@State private var displayEditHitoryView = false
    //@State private var selectedTraining: WorkoutHistoryElement? = nil
    @State private var visibleMonth: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
    @State private var trainingCount: Int = 0
    
    var visibleMonthName: String {
            guard let date = Calendar.current.date(from: visibleMonth) else { return "" }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM"
            return formatter.string(from: date)
        }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView {
                    //                VStack {
                    //                     //Search bar
                    //                    HStack {
                    //                        Image(systemName: "magnifyingglass") // Use system icon for magnifier
                    //                            .foregroundColor(.gray) // Set the color of the icon
                    //                            .padding(.leading, 10)
                    //
                    //                        TextField("Search in history...", text: $searchText)
                    //                            .padding(10) // Padding inside the text field
                    //                            .frame(height: 35)
                    //                            .onChange(of: searchText) { _, newText in
                    //                                filterSearchResults()
                    //                            }
                    //
                    //                    }
                    //
                    //                    .background(Color.ShadowColor) // Background color similar to Android search view
                    //                    .cornerRadius(10)
                    //                    .padding(.horizontal, 20)
                    //
                    //                    // Workout history list (Equivalent to RecyclerView)
                    //                    HistoryListView(viewModel: viewModel)
                    //                }
                    //                .searchable(text: $searchText)
                    //
                    //            }
                    //            .onAppear() {
                    //                viewModel.loadHistory()
                    CalendarView(
                        interval: DateInterval(start: .distantPast, end: .distantFuture),
                        historyElements: workoutHistoryElements,
                        dateSelected: $dateSelected,
                        displayHistorySheet: $displayTrainings,
                        visibleMonth: $visibleMonth,
                        trainingCount: $trainingCount
                    )
                    .frame(width: geometry.size.width)
                    .id(workoutHistoryElements.history.count)
                    .onAppear {
                        workoutHistoryElements.fetchTrainings()
                    }
//                    NavigationLink(
//                        isActive: $displayEditHitoryView,
//                        destination: {
//                            if let selectedTraining = selectedTraining {
//                                EditHistoryDetailsView(
//                                    historyElementViewModel: HistoryElementViewModel(historyElement: selectedTraining, position: 0)
//                                )
//                            } else {
//                                EmptyView()
//                            }
//                        },
//                        label: { EmptyView() }
//                    )
                }
                Spacer()
                
                HStack {
                    let textSize: CGFloat = 12
                    let valueSize: CGFloat = 18
                    VStack {
                        Text("THIS WEEK:")
                            .font(.system(size: textSize))
                            .foregroundStyle(Color.accentColor)
                        Text("\(countTrainings().sinceLastSunday)")
                            .font(.system(size: valueSize))
                            .foregroundStyle(Color.accentColor)
                            .contentTransition(.numericText())
                        Text("trainings done")
                            .font(.system(size: textSize))
                            .foregroundStyle(Color.textColorSecondary)
                    }
                    
                    Spacer()
                    
                    
                    VStack {
                        Text("THIS MONTH")
                            .font(.system(size: textSize))
                            .foregroundStyle(Color.accentColor)
                        Text("\(countTrainings().sinceMonthStart)")
                            .font(.system(size: valueSize))
                            .foregroundStyle(Color.accentColor)
                            .contentTransition(.numericText())
                        Text("trainings done")
                            .font(.system(size: textSize))
                            .foregroundStyle(Color.textColorSecondary)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("IN \(visibleMonthName.uppercased())")
                            .font(.system(size: textSize))
                            .foregroundStyle(Color.accentColor)
                        Text("\(trainingCount)")
                            .font(.system(size: valueSize))
                            .foregroundStyle(Color.accentColor)
                            .contentTransition(.numericText())
                        Text("trainings done")
                            .font(.system(size: textSize))
                            .foregroundStyle(Color.textColorSecondary)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .toast(isShowing: $viewModel.showToast, message: viewModel.toastMessage)
            .sheet(isPresented: $displayTrainings) {
                HistoryDialog(historyElements: workoutHistoryElements ,dateSelected: $dateSelected)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private var foundTraining: WorkoutHistoryElement {
        let emptyElement = WorkoutHistoryElement(planName: "", routineName: "", formattedDate: "", rawDate: "")
        if let dateSelected {
            return workoutHistoryElements.history
                .first(where: { CustomDate.rawStringToDate($0.rawDate)?.startOfDay == dateSelected.date!.startOfDay }) ?? emptyElement
        }
        return emptyElement
    }
    
    
    private func filterSearchResults() {
        if searchText.isEmpty {
            viewModel.filteredHistory = viewModel.history
        } else {
            let lowercasedQuery = searchText.lowercased()
            viewModel.filteredHistory = viewModel.history.filter { historyItem in
                let planNameMatch = historyItem.planName.lowercased().starts(with: lowercasedQuery)
                let routineNameMatch = historyItem.routineName.lowercased().starts(with: lowercasedQuery)
                let dateMatch = historyItem.formattedDate.lowercased().contains(lowercasedQuery)
                
                return planNameMatch || routineNameMatch || dateMatch
            }
        }
    }
    
    private func countTrainings() -> (sinceLastSunday: Int, sinceMonthStart: Int) {
        let now = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        let lastSunday = calendar.date(from: components) ?? now
        
        let startOfMonthComponents = calendar.dateComponents([.year, .month], from: now)
        let startOfMonth = calendar.date(from: startOfMonthComponents) ?? now
        
        let sinceLastSunday = workoutHistoryElements.history.filter { element in
            guard let date = CustomDate.formattedStringToDate(element.formattedDate) else 
            { return false }
            return date >= lastSunday && date <= now
        }.count
        
        let sinceMonthStart = workoutHistoryElements.history.filter { element in
            guard let date = CustomDate.formattedStringToDate(element.formattedDate) else 
            { return false }
            return date >= startOfMonth && date <= now
        }.count
        
        return (sinceLastSunday, sinceMonthStart)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(WorkoutHistoryElements(preview: true))
    }
}
