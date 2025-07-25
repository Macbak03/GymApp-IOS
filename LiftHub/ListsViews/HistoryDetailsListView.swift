//
//  HistoryDetailsListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 17/09/2024.
//

import SwiftUI

struct HistoryDetailsListView: View {
    @ObservedObject var viewModel: HistoryDetailsViewModel
    
    @State private var isExpanded = false
    var body: some View {
        ScrollView {
            ForEach(viewModel.workout) { exercise in
                HistoryDetailsListExerciseView(viewModel: HistoryDetailsElementViewModel(exercise: exercise, planName: viewModel.historyElement.planName))
            }
        }
    }
}

private struct HistoryDetailsListExerciseView: View {
    @StateObject var viewModel: HistoryDetailsElementViewModel
    
    @State private var isDetailsVisible = false
    @State private var displayNote = false
    
    private let textSize: CGFloat = 15
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isDetailsVisible ? 0 : -90))
                .frame(width: 20, height: 20)
                .padding(.leading, 15)
            VStack(alignment: .leading, spacing: 3) {
                // First Horizontal Layout (Exercise Name)
                HStack {
                    Text(viewModel.exercise.workoutExerciseDraft.name)
                        .font(.system(size: 18, weight: .bold))
                        .frame(height: 15)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                if viewModel.planName != Constants.NO_PLAN_NAME && viewModel.exercise.workoutExerciseDraft.pause != "0" && viewModel.exercise.workoutExerciseDraft.pace != "0000" {
                    
                    // Second Horizontal Layout (Rest, Series, Intensity, Pace)
                    HStack(alignment: .center) {
                        let VSpacing: CGFloat = 2
                        // Rest Layout
                        HStack(spacing: VSpacing) {
                            Text("Rest:")
                                .font(.system(size: textSize))
                            HStack(spacing: 1) {
                                Text(viewModel.exercise.workoutExerciseDraft.pause)
                                    .font(.system(size: textSize))
                                    .frame(alignment: .trailing)
                                
                                Text(viewModel.exercise.workoutExerciseDraft.pauseUnit.rawValue)
                                    .font(.system(size: textSize))
                                    .frame(alignment: .leading)
                            }
                        }
                        .frame(width: 110, alignment: .leading)
                        .foregroundStyle(Color.TextColorSecondary)
    //                    Spacer()
    //                    // Series Layout
    //                    VStack(spacing: VSpacing) {
    //                        Text("Series:")
    //                            .font(.system(size: textSize))
    //                        Text(viewModel.seriesValue)
    //                            .font(.system(size: textSize))
    //                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
    //                    }
    //                    Spacer()
    //                    // Intensity Layout
    //                    VStack(spacing: VSpacing) {
    //                        Text("\(viewModel.intensityIndexText):")
    //                            .font(.system(size: textSize))
    //                        Text(viewModel.intensityValue)
    //                            .font(.system(size: textSize))
    //                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
    //                    }
                        //Spacer()
                        // Pace Layout
                        HStack(spacing: VSpacing) {
                            Text("Pace:")
                                .font(.system(size: textSize))
                            Text(viewModel.exercise.workoutExerciseDraft.pace ?? "-")
                                .font(.system(size: textSize))
                                //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                        }
                        .foregroundStyle(Color.TextColorSecondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: (viewModel.planName != Constants.NO_PLAN_NAME) ? 40 : 35)
            .padding(.horizontal, 10)  // General padding for the whole view
        }
        .onTapGesture {
            withAnimation {
                isDetailsVisible.toggle()
            }
        }
        Divider()
            .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
            .background(Color(.systemGray6)) // Set color for the line
        if isDetailsVisible {
            ForEach(viewModel.exercise.workoutSeriesDraftList.indices, id: \.self) {
                index in
                HistoryDetailsListSeriesView(series: $viewModel.exercise.workoutSeriesDraftList[index], position: index)
            }
            // Note Input
            if(!viewModel.exercise.workoutExerciseDraft.note.isEmpty){
                Text(viewModel.exercise.workoutExerciseDraft.note)
                    .font(.system(size: textSize))
                    .padding(.leading, 15)
                    .padding(.trailing, 10)
                    .padding(.bottom, 3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider()
                .frame(maxWidth: .infinity, maxHeight: 2)
                .background(Color(.systemGray6))
        }
        
    }
}

private struct HistoryDetailsListSeriesView: View {
    @Binding var series: WorkoutSeriesDraft
    let position: Int
    private let textSize: CGFloat = 15

    
    var body: some View {
        // First Horizontal Layout for Series Count, Reps, Weight
        ZStack {
            // First HStack for Series Count on the left
            HStack {
                Text("\(position + 1).")
                    .font(.system(size: textSize))
                    .padding(.leading, 4)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Second HStack for Reps, x, Weight, and LoadUnit in the center
            HStack(spacing: 2) {
                Text(series.actualReps)
                    .font(.system(size: textSize))
                    .frame(height: 25)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 2)
                
                Text("x")
                    .font(.system(size: textSize))
                    .frame(width: 10)
                    .multilineTextAlignment(.center)
                
                Text(series.actualLoad)
                    .font(.system(size: textSize))
                    .frame(height: 25)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 2)
                
                Text(series.loadUnit.rawValue)
                    .font(.system(size: textSize))
            }
            .frame(maxWidth: .infinity, alignment: .center) // Center the HStack
            .padding(.horizontal, 85)
            
            // Third HStack for Intensity Value on the right
            if series.actualIntensity != nil {
                HStack {
                    Divider()
                        .frame(width: 2, height: 25)  // Vertical line, adjust height as needed
                        .background(Color(.systemGray6)) // Set color for the line
                        .padding(.trailing, 5)
                    
                    Text("\(series.intensityIndex.rawValue):")
                        .font(.system(size: textSize))
                    
                    Text(series.actualIntensity!)
                        .frame(width: 25, height: 25)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 5)
                }
                .frame(maxWidth: .infinity, alignment: .trailing) // Align the HStack to the right
            }
        }
        .padding(.top, 2)  // Equivalent to layout_marginTop="5dp"
        .padding(.horizontal, 10)
    }
}

struct HistoryDetailsListView_previews: PreviewProvider {
    @State static var exercise1 = WorkoutExerciseDraft(name: "Exercise1", pause: "1", pauseUnit: TimeUnit.min, series: "1", reps: "1", loadUnit: WeightUnit.kg, intensity: "1", intensityIndex: IntensityIndex.RPE, pace: "1111", note: "note1")
    @State static var series1_1 = WorkoutSeriesDraft(actualReps: "11", actualLoad: "11", loadUnit: WeightUnit.kg, intensityIndex: IntensityIndex.RPE, actualIntensity: "1")
    
    @State static var wholeExercise1 = (workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1])
    
    @State static var exercise2 = WorkoutExerciseDraft(name: "Exercise2", pause: "2", pauseUnit: TimeUnit.s, series: "2", reps: "2", loadUnit: WeightUnit.lbs, intensity: "2", intensityIndex: IntensityIndex.RIR, pace: "2222", note: "note2")
    @State static var series2_1 = WorkoutSeriesDraft(actualReps: "21", actualLoad: "21", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "2")
    @State static var series2_2 = WorkoutSeriesDraft(actualReps: "22", actualLoad: "222", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "3")
    
    @State static var wholeExercise2 = (workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])
    
    @State static var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])] =  [(workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1]), (workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])]
    
    @State static var workoutHint1 = WorkoutHints(repsHint: "1", weightHint: "1", intensityHint: "1", noteHint: "Note1")
    @State static var workoutHint2 = WorkoutHints(repsHint: "2", weightHint: "2", intensityHint: "2", noteHint: "Note2")
    @State static var workoutHints = [workoutHint1, workoutHint2]
    
    @State static var showToast = false
    @State static var toastMessage = ""
    
    static var previews: some View {
        HistoryDetailsListView(viewModel: HistoryDetailsViewModel(historyElement: WorkoutHistoryElement(planName: "", routineName: "", formattedDate: "", rawDate: "")))
    }
}

