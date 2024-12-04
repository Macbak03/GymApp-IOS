//
//  WorkoutListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 13/09/2024.
//
import Foundation
import SwiftUI

struct WorkoutListView: View {
    @Binding var workout: [WorkoutDraft]
    @Binding var workoutHints: [WorkoutHints]
    @ObservedObject var workoutStateViewModel: WorkoutStateViewModel

    var body: some View {
        ScrollView {
            ForEach(workout.indices, id: \.self) {
                index in
                WorkoutListExerciseView(exercise: $workout[index], workoutHints: $workoutHints[index], workoutStateViewModel: workoutStateViewModel)
            }
        }
    }
}

private struct WorkoutListExerciseView: View {
    @Binding var exercise: WorkoutDraft
    @Binding var workoutHints: WorkoutHints
    
    @ObservedObject var workoutStateViewModel: WorkoutStateViewModel
    @StateObject private var viewModel =  WorkoutExerciseViewModel()
    
    @State private var displayNote = false
    
    private let textSize: CGFloat = 15
    private let outllineFrameHeight: CGFloat = 30
    
    @State private var isSaveClicked = false
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(viewModel.areDetailsVisible ? 0 : -90))
                .frame(width: 20, height: 20)
                .padding(.leading, 15)
            VStack(alignment: .leading, spacing: 3) {
                // First Horizontal Layout (Exercise Name)
                HStack {
                    Text(viewModel.exerciseName)
                        .font(.system(size: 18, weight: .bold))  // Equivalent to bold and textSize 24sp
                        .frame(height: 15)  // Equivalent to layout_height="30dp"
                    //.padding(.leading, 35)  // Equivalent to layout_marginStart="35dp"
                    Spacer()  // To take up the remaining space
                }
                .frame(maxWidth: .infinity)
                
                // Second Horizontal Layout (Rest, Series, Intensity, Pace)
                HStack(alignment: .center) {
                    let VSpacing: CGFloat = 2
                    // Rest Layout
                    VStack(spacing: VSpacing) {
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
                    Spacer()
                    // Series Layout
                    VStack(spacing: VSpacing) {
                        Text("Series:")
                            .font(.system(size: textSize))
                        Text(viewModel.seriesValue)
                            .font(.system(size: textSize))
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    }
                    Spacer()
                    // Intensity Layout
                    VStack(spacing: VSpacing) {
                        Text("\(viewModel.intensityIndexText):")
                            .font(.system(size: textSize))
                        Text(viewModel.intensityValue)
                            .font(.system(size: textSize))
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    }
                    Spacer()
                    // Pace Layout
                    VStack(spacing: VSpacing) {
                        Text("Pace:")
                            .font(.system(size: textSize))
                        Text(viewModel.paceValue)
                            .font(.system(size: textSize))
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 15)
            }
            .padding(.horizontal, 10)  // General padding for the whole view
        }
        .onTapGesture {
            withAnimation {
                viewModel.areDetailsVisible.toggle()
            }
        }
        .onAppear() {
            viewModel.initValues(workoutExerciseDraft: exercise.workoutExerciseDraft, workoutHints: workoutHints)
        }
        .onChange(of: workoutStateViewModel.isSaveClicked) { _, clicked in
            if clicked {
                viewModel.areDetailsVisible = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                    isSaveClicked = true
                }
            }
        }
        Divider()
            .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
            .background(Color(.systemGray6)) // Set color for the line
        if viewModel.areDetailsVisible {
            ForEach(exercise.workoutSeriesDraftList.indices, id: \.self) {
                index in
                WorkoutListSeriesView(series: $exercise.workoutSeriesDraftList[index], workoutHint: $workoutHints, stateViewModel: workoutStateViewModel, viewModel: WorkoutSeriesViewModel(seriesCount: exercise.workoutSeriesDraftList.count, position: index), isSaveClicked: $isSaveClicked)
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
            Divider()
                .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
                .background(Color(.systemGray6)) // Set color for the line
        }
        
    }
}

private struct WorkoutListSeriesView: View {
    @Binding var series: WorkoutSeriesDraft
    @Binding var workoutHint: WorkoutHints
    @ObservedObject var stateViewModel: WorkoutStateViewModel
    @StateObject var viewModel: WorkoutSeriesViewModel
    
    @Binding var isSaveClicked: Bool

    
    @FocusState private var isLoadFocused: Bool
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isIntensityFocused: Bool


    private let textFieldCornerRadius: CGFloat = 5
    private let textFieldStrokeLineWidth: CGFloat = 0.5
    
    private let textSize: CGFloat = 15
    private let outllineFrameHeight: CGFloat = 25
    
    @State private var showLoadToolbar = false
    @State private var showRepsToolbar = false
    @State private var showIntensityToolbar = false

    
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
                    .onChange(of: isRepsFocused) { _, focused in
                        viewModel.validateReps(focused: focused, series: series, stateViewModel: stateViewModel)
                        showRepsToolbar = focused
                    }
                    .toolbar {
                        if showRepsToolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                CustomKeyboardToolbar(textFieldValue: $series.actualReps)
                            }
                        }
                    }
                
                // Multiplication Sign
                Text("x")
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
                    .onChange(of: isLoadFocused) { _, focused in
                        viewModel.validateLoad(focused: focused, series: series, stateViewModel: stateViewModel)
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
                Text("\(viewModel.intensityIndexText):")
                    .font(.system(size: textSize))
                // Intensity Input
                TextField(viewModel.intensityHint, text: $series.actualIntensity)
                    .keyboardType(.decimalPad)
                    .font(.system(size: textSize))
                    .frame(width: 40, height: outllineFrameHeight)
                    .multilineTextAlignment(.leading)// Equivalent to textAlignment="textEnd"
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: textFieldCornerRadius)
                            .stroke((viewModel.showIntensityError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                    )
                    .focused($isIntensityFocused)
                    .onChange(of: isIntensityFocused) { _, focused in
                        viewModel.validateIntensity(focused: focused, series: series, stateViewModel: stateViewModel)
                        showIntensityToolbar = focused
                    }
                    .toolbar {
                        if showIntensityToolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                CustomKeyboardToolbar(textFieldValue: $series.actualIntensity)
                            }
                        }
                    }
                    .padding(.trailing, 5)
                
            }
            .padding(.top, 2)  // Equivalent to layout_marginTop="5dp"
            .padding(.horizontal, 10)
        }
        .onAppear() {
            viewModel.initValues(series: series, hint: workoutHint)
        }
        .onChange(of: isSaveClicked) { _, clicked in
            if isSaveClicked {
                do {
                    try convertHintsToData(stateViewModel: stateViewModel)
                } catch let error as ValidationException {
                    stateViewModel.showToast = true
                    stateViewModel.toastMessage = error.message
                } catch {
                    stateViewModel.showToast = true
                    print("Unexpected error occured when converting hints: \(error)")
                }
            }
        }
    }
    
    func convertHintsToData(stateViewModel: WorkoutStateViewModel) throws {
        if series.actualReps.isEmpty {
            guard let _ = Double(viewModel.repsHint) else {
                viewModel.showRepsError = true
                stateViewModel.isSaveClicked = false
                throw ValidationException(message: "Reps can't be in ranged value")
            }
            series.actualReps = viewModel.repsHint
        }
        
        if series.actualLoad.isEmpty {
            series.actualLoad = viewModel.weightHint
        }
        
        if series.actualIntensity.isEmpty {
            guard let _ = Int(viewModel.intensityHint) else {
                viewModel.showIntensityError = true
                stateViewModel.isSaveClicked = false
                throw ValidationException(message: "\(series.intensityIndex) can't be in ranged or floating point number value")
            }
            series.actualIntensity = viewModel.intensityHint
        }
        
    }
}

struct WorkoutListView_previews: PreviewProvider {
    @State static var exercise1 = WorkoutExerciseDraft(name: "Exercise1", pause: "3-5", pauseUnit: TimeUnit.min, series: "1", reps: "1", intensity: "1", intensityIndex: IntensityIndex.RPE, pace: "1111", note: "note1")
    @State static var series1_1 = WorkoutSeriesDraft(actualReps: "11", actualLoad: "11", loadUnit: WeightUnit.kg, intensityIndex: IntensityIndex.RPE, actualIntensity: "1")
    
    @State static var wholeExercise1 = WorkoutDraft(workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1])
    
    @State static var exercise2 = WorkoutExerciseDraft(name: "Exercise2", pause: "2", pauseUnit: TimeUnit.s, series: "2", reps: "2", intensity: "2", intensityIndex: IntensityIndex.RIR, pace: "2222", note: "note2")
    @State static var series2_1 = WorkoutSeriesDraft(actualReps: "21", actualLoad: "21", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "2")
    @State static var series2_2 = WorkoutSeriesDraft(actualReps: "22", actualLoad: "22", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "3")
    
    @State static var wholeExercise2 = WorkoutDraft(workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])
    
    @State static var workout =  [wholeExercise1, wholeExercise2]
    
    @State static var workoutHint1 = WorkoutHints(repsHint: "1", weightHint: "1", intensityHint: "1", noteHint: "Note1")
    @State static var workoutHint2 = WorkoutHints(repsHint: "2", weightHint: "2", intensityHint: "2", noteHint: "Note2")
    @State static var workoutHints = [workoutHint1, workoutHint2]
    
    @State static var showToast = false
    @State static var toastMessage = ""
    
    static var previews: some View {
        WorkoutListView(workout: $workout, workoutHints: $workoutHints, workoutStateViewModel: WorkoutStateViewModel())
//        WorkoutListExerciseView(exercise: $wholeExercise2)
//        WorkoutListSeriesView(series: $series1_1, seriesCount: 0, position: 0)
    }
}
