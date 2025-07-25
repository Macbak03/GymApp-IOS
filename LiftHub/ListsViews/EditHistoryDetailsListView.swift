//
//  EditHistoryDetailsListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 17/09/2024.
//

import Foundation
import SwiftUI

struct EditHistoryDetailsListView: View {
    @ObservedObject var viewModel: EditHistoryDetailsViewModel

    var body: some View {
        ScrollView {
            ForEach(viewModel.workoutDraft.indices, id: \.self) {
                index in
                EditHistoryDetailsListExerciseView(exercise: $viewModel.workoutDraft[index], editHistoryDetailsViewModel: viewModel, viewModel: EditHistoryDetailsElementViewModel(planName: viewModel.planName, position: index))
            }
        }
    }
}

private struct EditHistoryDetailsListExerciseView: View {
    @Binding var exercise: WorkoutDraft
    @ObservedObject var editHistoryDetailsViewModel: EditHistoryDetailsViewModel
    @StateObject var viewModel: EditHistoryDetailsElementViewModel
    
    @State private var isDetailsVisible = false
    @State private var workoutModified = false
    
    private let textSize: CGFloat = 15
    private let outllineFrameHeight: CGFloat = 30

    
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isDetailsVisible ? 0 : -90))
                .frame(width: 20, height: 20)
                .padding(.leading, 15)
            VStack(alignment: .leading, spacing: 3) {
                // First Horizontal Layout (Exercise Name)
                HStack {
                    Text(viewModel.exerciseName)
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                if viewModel.planName != Constants.NO_PLAN_NAME {
                    // Second Horizontal Layout (Rest, Series, Intensity, Pace)
                    HStack(alignment: .center) {
                        let VSpacing: CGFloat = 2
                        // Rest Layout
                        HStack(spacing: VSpacing) {
                            Text("Rest:")
                                .font(.system(size: textSize))
                            HStack(spacing: 1) {
                                Text(viewModel.restValue)
                                    .font(.system(size: textSize))
                                    .frame(alignment: .trailing)
                                
                                Text(viewModel.restUnit)
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
                            Text(viewModel.paceValue ?? "-")
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
        .onAppear() {
            viewModel.initValues(workoutExerciseDraft: exercise.workoutExerciseDraft)
        }
        Divider()
            .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
            .background(Color(.systemGray6)) // Set color for the line
        if isDetailsVisible {
            ForEach(exercise.workoutSeriesDraftList.indices, id: \.self) {
                index in
                HistoryDetailsListSeriesView(
                    series: $exercise.workoutSeriesDraftList[index],
                    editHistoryDetailsViewModel: editHistoryDetailsViewModel,
                    viewModel: EditHistoryDetailsSeriesViewModel(seriesCount: exercise.workoutSeriesDraftList.count, position: index, exerciseType: exercise.workoutExerciseDraft.exerciseType),
                    workoutModified: $workoutModified
                )
            }
            // Note Input
            TextField(viewModel.noteHint, text: $exercise.workoutExerciseDraft.note)
                .font(.system(size: textSize))
                .frame(height: outllineFrameHeight)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.textFieldOutline, lineWidth: 0.5)
                )
                .padding(.horizontal, 15)
            
            if exercise.workoutExerciseDraft.exerciseType != .timed {
                HStack(spacing: 3) {
                    Text("Volume:")
                        .font(.system(size: textSize))
                        .bold()
                    Text(viewModel.volumeValue.description)
                        .font(.system(size: textSize))
                        .onAppear {
                            viewModel.volumeValue = calculateVolume()
                        }
                        .onChange(of: workoutModified) { _, modified in
                            if modified {
                                viewModel.volumeValue = calculateVolume()
                                workoutModified = false
                            }
                        }
                    Text(exercise.workoutSeriesDraftList.first?.loadUnit.description ?? "-")
                        .font(.system(size: textSize))
                }
                .foregroundStyle(Color.TextColorSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
            }
            Divider()
                .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
                .background(Color(.systemGray6)) // Set color for the line
        }
        
    }
    
    private func calculateVolume() -> Double {
        var volumeValue = 0.0
        exercise.workoutSeriesDraftList.forEach { series in
            volumeValue += (Double(series.actualLoad) ?? 0.0) * (Double(series.actualReps) ?? 0.0)
        }
        
        return volumeValue
    }
}

private struct HistoryDetailsListSeriesView: View {
    @Binding var series: WorkoutSeriesDraft
    @ObservedObject var editHistoryDetailsViewModel: EditHistoryDetailsViewModel
    @StateObject var viewModel: EditHistoryDetailsSeriesViewModel
    @Binding var workoutModified: Bool
    @FocusState private var isLoadFocused: Bool
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isIntensityFocused: Bool
    
    private let textFieldCornerRadius: CGFloat = 5
    private let textFieldStrokeLineWidth: CGFloat = 0.5
    
    @State private var showLoadToolbar = false
    @State private var showRepsToolbar = false
    @State private var showIntensityToolbar = false
    
    private let textSize: CGFloat = 15
    private let outllineFrameHeight: CGFloat = 25
    
    
    var body: some View {
        VStack(alignment: .leading) {
            // First Horizontal Layout for Series Count, Reps, Weight
            HStack(spacing: 5) {
                // Series Count
                Text("\(viewModel.position + 1).")
                    .font(.system(size: textSize))
                    .padding(.leading, 4) // Equivalent to layout_marginStart="10dp"
                
                // Reps Input
                TextField(viewModel.repsHint, text: $series.actualReps)
                    .keyboardType(.decimalPad)
                    .font(.system(size: textSize))
                    .frame(height: outllineFrameHeight)
                    .multilineTextAlignment(.trailing)// Equivalent to textAlignment="textEnd"
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: textFieldCornerRadius)
                            .stroke((viewModel.showRepsError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                    )
                    .focused($isRepsFocused)
                    .onChange(of: series.actualReps) { _, _ in
                        workoutModified = true
                    }
                    .onChange(of: isRepsFocused) { _, focused in
                        viewModel.validateReps(focused: focused, parentViewModel: editHistoryDetailsViewModel, series: series)
                        showRepsToolbar = focused
                    }
                    .toolbar {
                        if showRepsToolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                CustomKeyboardToolbar(textFieldValue: $series.actualReps)
                            }
                        }
                    }
                    .onAppear() {
                        if viewModel.repsHint == "Reps" && viewModel.exerciseType == .timed {
                            viewModel.repsHint = "Time"
                        }
                    }
                
                Text(viewModel.exerciseType == .timed ? "s" : "x")
                    .font(.system(size: textSize))
                    .frame(width: 10)
                    .multilineTextAlignment(.center)
                
                // Weight Input
                TextField(viewModel.weightHint, text: $series.actualLoad)
                    .keyboardType(.decimalPad)
                    .font(.system(size: textSize))
                    .frame(height: outllineFrameHeight)
                    .multilineTextAlignment(.leading)// Equivalent to textAlignment="textEnd"
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: textFieldCornerRadius)
                            .stroke((viewModel.showLoadError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                    )
                    .focused($isLoadFocused)
                    .onChange(of: series.actualLoad) { _, _ in
                        workoutModified = true
                    }
                    .onChange(of: isLoadFocused) { _, focused in
                        viewModel.validateLoad(focused: focused, parentViewModel: editHistoryDetailsViewModel, series: series)
                        showLoadToolbar = focused
                    }
                    .toolbar {
                        if showLoadToolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                CustomKeyboardToolbar(textFieldValue: $series.actualLoad)
                            }
                        }
                    }
                
                // Weight Unit Value
                Text(viewModel.weightUnitText)  // Assuming the weight unit is kilograms
                    .font(.system(size: textSize))
                
                Divider()
                    .frame(width: 2, height: 25)  // Vertical line, adjust height as needed
                    .background(Color(.systemGray6)) // Set color for the line
                
                // Intensity Value
                if series.actualIntensity != nil {
                    Text("\(viewModel.intensityIndexText):")
                        .font(.system(size: textSize))
                    // Intensity Input
                    TextField(viewModel.intensityHint, text: $viewModel.intensityValue)
                        .keyboardType(.decimalPad)
                        .font(.system(size: textSize))
                        .frame(width: 40,height: 25)
                        .multilineTextAlignment(.leading)// Equivalent to textAlignment="textEnd"
                        .padding(.horizontal, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                .stroke((viewModel.showIntensityError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                        )
                        .focused($isIntensityFocused)
                        .onChange(of: viewModel.intensityValue) { _, intensity in
                            series.actualIntensity = intensity
                        }
                        .onChange(of: isIntensityFocused) { _, focused in
                            viewModel.validateIntensity(focused: focused, parentViewModel: editHistoryDetailsViewModel, series: series)
                            showIntensityToolbar = focused
                        }
                        .toolbar {
                            if showIntensityToolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    CustomKeyboardToolbar(textFieldValue: $viewModel.intensityValue)
                                }
                            }
                        }
                        .padding(.trailing, 5)
            }
                
            }
            .padding(.top, 5)  // Equivalent to layout_marginTop="5dp"
            .padding(.horizontal, 10)
        }
        .onAppear() {
            viewModel.initValues(series: series)
        }
    }
}
    

struct EditHistoryDetailsListView_previews: PreviewProvider {
    @State static var exercise1 = WorkoutExerciseDraft(name: "Exercise1", pause: "3-5", pauseUnit: TimeUnit.min, series: "1", reps: "1", loadUnit: WeightUnit.kg, intensity: "1", intensityIndex: IntensityIndex.RPE, pace: "1111", note: "note1")
    @State static var series1_1 = WorkoutSeriesDraft(actualReps: "11", actualLoad: "11", loadUnit: WeightUnit.kg, intensityIndex: IntensityIndex.RPE, actualIntensity: "1")
    
    @State static var wholeExercise1 = (workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1])
    
    @State static var exercise2 = WorkoutExerciseDraft(name: "Exercise2", pause: "2", pauseUnit: TimeUnit.s, series: "2", reps: "2", loadUnit: WeightUnit.lbs, intensity: "2", intensityIndex: IntensityIndex.RIR, pace: "2222", note: "note2")
    @State static var series2_1 = WorkoutSeriesDraft(actualReps: "21", actualLoad: "21", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "2")
    @State static var series2_2 = WorkoutSeriesDraft(actualReps: "22", actualLoad: "22", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "3")
    
    @State static var wholeExercise2 = (workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])
    
    @State static var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])] =  [(workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1]), (workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])]
    
    @State static var workoutHint1 = WorkoutHints(repsHint: "1", weightHint: "1", intensityHint: "1", noteHint: "Note1")
    @State static var workoutHint2 = WorkoutHints(repsHint: "2", weightHint: "2", intensityHint: "2", noteHint: "Note2")
    @State static var workoutHints = [workoutHint1, workoutHint2]
    
    @State static var showToast = false
    @State static var toastMessage = ""
    
    static var previews: some View {
        EditHistoryDetailsListView(viewModel: EditHistoryDetailsViewModel())
//        WorkoutListExerciseView(exercise: $wholeExercise2)
//        WorkoutListSeriesView(series: $series1_1, seriesCount: 0, position: 0)
    }
}

