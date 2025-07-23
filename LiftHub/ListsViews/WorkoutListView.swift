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
    let planName: String
    let routineName: String

    var body: some View {
        ScrollView {
            ForEach(workout.indices, id: \.self) {
                index in
                WorkoutListExerciseView(exercise: $workout[index], workoutHints: $workoutHints[index], workoutStateViewModel: workoutStateViewModel, planName: planName, routineName: routineName)
            }
        }
    }
}

private struct WorkoutListExerciseView: View {
    @Binding var exercise: WorkoutDraft
    @Binding var workoutHints: WorkoutHints
    
    @ObservedObject var workoutStateViewModel: WorkoutStateViewModel
    @StateObject private var viewModel =  WorkoutExerciseViewModel()
    
    let planName: String
    let routineName: String
    
    @State private var displayNote = false
    
    private let textSize: CGFloat = 15
    private let outllineFrameHeight: CGFloat = 30
    
    @State private var isSaveClicked = false
    
    @State private var defaultSetComparison = WorkoutHints(repsHint: "reps", weightHint: UserDefaultsUtils.shared.getWeightUnit(),  intensityHint: UserDefaultsUtils.shared.getIntensity(), noteHint: "note")
    @State private var workoutModified = false
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
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                    Spacer()
                }
                
                
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
                    // Pace Layout
                    if exercise.workoutExerciseDraft.exerciseType != .timed {
                        HStack(spacing: VSpacing) {
                            Text("Pace:")
                                .font(.system(size: textSize))
                            Text(viewModel.paceValue ?? "-")
                                .font(.system(size: textSize))
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                        }
                        .foregroundStyle(Color.TextColorSecondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                //.padding(.horizontal, 15)
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
            viewModel.loadLastWorkoutComparison(planName: planName, routineName: routineName)
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
            Menu {
                Picker(selection: $viewModel.selectedComparingMethod) {
                    Text(SelectedComparingMethod.lastWorkout.description).tag(SelectedComparingMethod.lastWorkout)
                    Text(SelectedComparingMethod.trainingPlan.description).tag(SelectedComparingMethod.trainingPlan)
                } label: {}
            } label: {
                HStack {
                    Text(viewModel.selectedComparingMethod.description)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.MenuPickerColorSecondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundStyle(Color.MenuPickerColorSecondary)
                }
            }
            ForEach(exercise.workoutSeriesDraftList.indices, id: \.self) {
                index in
                if index < viewModel.lastWorkoutComparison.count {
                    WorkoutListSeriesView(
                        series: $exercise.workoutSeriesDraftList[index],
                        workoutHint: $workoutHints,
                        setComparison: $viewModel.lastWorkoutComparison[index],
                        stateViewModel: workoutStateViewModel,
                        viewModel: WorkoutSeriesViewModel(seriesCount: exercise.workoutSeriesDraftList.count, position: index),
                        isSaveClicked: $isSaveClicked,
                        selectedComparisonMethod: $viewModel.selectedComparingMethod,
                        workoutModified: $workoutModified,
                        isExerciseTimed: exercise.workoutExerciseDraft.exerciseType == .timed
                    )
                } else {
                    WorkoutListSeriesView(
                        series: $exercise.workoutSeriesDraftList[index],
                        workoutHint: $workoutHints,
                        setComparison: $defaultSetComparison,
                        stateViewModel: workoutStateViewModel,
                        viewModel: WorkoutSeriesViewModel(seriesCount: exercise.workoutSeriesDraftList.count, position: index),
                        isSaveClicked: $isSaveClicked,
                        selectedComparisonMethod: $viewModel.selectedComparingMethod,
                        workoutModified: $workoutModified,
                        isExerciseTimed: exercise.workoutExerciseDraft.exerciseType == .timed
                    )
                }
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
                HStack {
                    HStack(spacing: 3) {
                        Text("Volume:")
                            .font(.system(size: textSize))
                            .bold()
                        Text(viewModel.volumeValue.description)
                            .font(.system(size: textSize))
                            .onChange(of: workoutModified) { _, modified in
                                if modified {
                                    viewModel.volumeValue = calculateVolume()
                                    viewModel.volumeDifference = calculateVolumeDifference()
                                    workoutModified = false
                                }
                            }
                        Text(exercise.workoutSeriesDraftList.first?.loadUnit.description ?? "-")
                            .font(.system(size: textSize))
                        if viewModel.volumeValue > viewModel.lastTrainingVolumeValue ?? 0 {
                            Text("(")
                                .font(.system(size: textSize))
                            Image(systemName: "arrow.up")
                                .foregroundStyle(.green)
                                .font(.system(size: textSize))
                                .scaleEffect(CGSize(width: 0.8, height: 0.8))
                            Text(viewModel.volumeDifference.description)
                                .font(.system(size: textSize))
                                .foregroundStyle(.green)
                            Text(exercise.workoutSeriesDraftList.first?.loadUnit.description ?? "-")
                                .font(.system(size: textSize))
                                .foregroundStyle(.green)
                            Text(")")
                                .font(.system(size: textSize))
                        } else if viewModel.volumeValue < viewModel.lastTrainingVolumeValue ?? 0.0 {
                            Text("(")
                                .font(.system(size: textSize))
                            Image(systemName: "arrow.down")
                                .foregroundStyle(.red)
                                .font(.system(size: textSize))
                                .scaleEffect(CGSize(width: 0.8, height: 0.8))
                            Text(viewModel.volumeDifference.description)
                                .font(.system(size: textSize))
                                .foregroundStyle(.red)
                            Text(exercise.workoutSeriesDraftList.first?.loadUnit.description ?? "-")
                                .font(.system(size: textSize))
                                .foregroundStyle(.red)
                            Text(")")
                                .font(.system(size: textSize))
                        } else {
                            Text("(")
                                .font(.system(size: textSize))
                            Image(systemName: "plusminus")
                                .font(.system(size: textSize))
                                .scaleEffect(CGSize(width: 0.8, height: 0.8))
                            Text("0")
                                .font(.system(size: textSize))
                            Text(exercise.workoutSeriesDraftList.first?.loadUnit.description ?? "-")
                                .font(.system(size: textSize))
                            Text(")")
                                .font(.system(size: textSize))
                        }
                        
                        
                    }
                    .onAppear {
                        viewModel.volumeValue = calculateVolume()
                        viewModel.lastTrainingVolumeValue = calculateLastTrainingVolume()
                        viewModel.volumeDifference = calculateVolumeDifference()
                    }
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
    
    private func calculateLastTrainingVolume() -> Double? {
        var lastTrainingVolumeValue: Double = 0.0
        viewModel.lastWorkoutComparison.forEach { comparison in
            lastTrainingVolumeValue += (Double(comparison.weightHint) ?? 0.0) * (Double(comparison.repsHint) ?? 0.0)
        }
        
        return lastTrainingVolumeValue
    }
    
    private func calculateVolumeDifference() -> Double {
        guard let lastVolume = viewModel.lastTrainingVolumeValue else {
            return viewModel.volumeValue
        }
        
        return abs(viewModel.volumeValue - lastVolume)
    }
}

private struct WorkoutListSeriesView: View {
    @Binding var series: WorkoutSeriesDraft
    @Binding var workoutHint: WorkoutHints
    @Binding var setComparison: WorkoutHints
    @ObservedObject var stateViewModel: WorkoutStateViewModel
    @StateObject var viewModel: WorkoutSeriesViewModel
    
    @Binding var isSaveClicked: Bool
    
    @Binding var selectedComparisonMethod: SelectedComparingMethod
    
    @Binding var workoutModified: Bool
    
    let isExerciseTimed: Bool
    
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
    
    @State private var compareWeight = false

    
    var body: some View {
        VStack(alignment: .leading) {
            // First Horizontal Layout for Series Count, Reps, Weight
            HStack(spacing: 5) {
                // Series Count
                Text("\(viewModel.position + 1).")
                    .font(.system(size: textSize))
                    .padding(.leading, 4) // Equivalent to layout_marginStart="10dp"
                    .frame(width: 20)
                
                
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
                    .onChange(of: series.actualReps) {
                        workoutModified = true
                    }
                    .toolbar {
                        if showRepsToolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                CustomKeyboardToolbar(textFieldValue: $series.actualReps)
                            }
                        }
                    }
                    .onAppear() {
                        if viewModel.repsHint == "reps" && isExerciseTimed {
                            viewModel.repsHint = "time"
                        }
                    }
                
                
                Text(isExerciseTimed ? "s" : "x")
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
                        compareWeight = !focused
                    }
                    .onChange(of: series.actualLoad) {
                        workoutModified = true
                    }
                    .toolbar {
                        if showLoadToolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                CustomKeyboardToolbar(textFieldValue: $series.actualLoad)
                            }
                        }
                    }
                
                // Weight Unit Value
                Text(viewModel.weightUnitText)
                    .font(.system(size: textSize))
                
                let compareResult = calculateAndCompareWeightDifference()
                if compareResult.value != 0 && compareWeight {
                    if compareResult.comparison == "more" {
                        HStack(spacing: 1) {
                            Image(systemName: "arrow.up")
                                .foregroundColor(Color.green)
                                .font(.system(size: textSize))
                                .scaleEffect(CGSize(width: 0.8, height: 0.8))
                            Text(compareResult.value.toStringWithFormat)
                                .font(.system(size: textSize))
                        }
                        .frame(width: 50)
                    }
                    if compareResult.comparison == "less" {
                        HStack(spacing: 1) {
                            Image(systemName: "arrow.down")
                                .foregroundColor(Color.red)
                                .font(.system(size: textSize))
                                .scaleEffect(CGSize(width: 0.8, height: 0.8))
                            Text(compareResult.value.toStringWithFormat).font(.system(size: textSize))
                        }
                        .frame(width: 50)
                    }
                }
                
                Divider()
                    .frame(width: 2, height: 25)
                    .background(Color(.systemGray6))
                
                // Intensity Value
                if series.actualIntensity != nil {
                    Text("\(viewModel.intensityIndexText):")
                        .font(.system(size: textSize))
                    // Intensity Input
                    TextField(viewModel.intensityHint!, text: $viewModel.intensityValue)
                        .keyboardType(.decimalPad)
                        .font(.system(size: textSize))
                        .frame(width: 40, height: outllineFrameHeight)
                        .multilineTextAlignment(.leading)
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
                            viewModel.validateIntensity(focused: focused, series: series, stateViewModel: stateViewModel)
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
            .padding(.top, 2)  // Equivalent to layout_marginTop="5dp"
            .padding(.horizontal, 10)
        }
        .onAppear() {
            viewModel.initValues(series: series, hint: workoutHint, setCompariosn: setComparison, selectedComparingMethod: selectedComparisonMethod)
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
        .onChange(of: selectedComparisonMethod) { _, _ in
            viewModel.reloadHints(hint: workoutHint, setCompariosn: setComparison, selectedComparingMethod: selectedComparisonMethod)
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
        if series.actualIntensity != nil && viewModel.intensityHint != nil{
            if series.actualIntensity!.isEmpty {
                guard let _ = Int(viewModel.intensityHint!) else {
                    viewModel.showIntensityError = true
                    stateViewModel.isSaveClicked = false
                    throw ValidationException(message: "\(series.intensityIndex) can't be in ranged or floating point number value")
                }
                series.actualIntensity = viewModel.intensityHint
            }
        }
        
    }
    
    func calculateAndCompareWeightDifference() -> (value: Double, comparison: String) {
        guard let comparingWeight = Double(setComparison.weightHint) else {
            return (value: 0, comparison: "")
        }
        guard let actualWeight = Double(series.actualLoad) else {
            return (value: 0, comparison: "")
        }
        if comparingWeight > actualWeight {
            return (value: comparingWeight - actualWeight, comparison: "less")
        }
        if comparingWeight < actualWeight {
            return (value: actualWeight - comparingWeight, comparison: "more")
        }
        return (value: 0, comparison: "")
    }
    
}

struct WorkoutListView_previews: PreviewProvider {
    @State static var exercise1 = WorkoutExerciseDraft(name: "Exercise1", pause: "59-60", pauseUnit: TimeUnit.min, series: "1", reps: "1", loadUnit: WeightUnit.kg, intensity: "10", intensityIndex: IntensityIndex.RPE, pace: "xxxx", note: "note1")
    @State static var series1_1 = WorkoutSeriesDraft(actualReps: "11", actualLoad: "11", loadUnit: WeightUnit.kg, intensityIndex: IntensityIndex.RPE, actualIntensity: "1")
    
    @State static var wholeExercise1 = WorkoutDraft(workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1])
    
    @State static var exercise2 = WorkoutExerciseDraft(exerciseType: .timed, name: "Exercise2", pause: "599-600", pauseUnit: TimeUnit.s, series: "2", reps: "2", loadUnit: WeightUnit.lbs, intensity: "2", intensityIndex: IntensityIndex.RIR, pace: "2222", note: "note2")
    @State static var series2_1 = WorkoutSeriesDraft(actualReps: "21", actualLoad: "21", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "2")
    @State static var series2_2 = WorkoutSeriesDraft(actualReps: "22", actualLoad: "22", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "3")
    
    @State static var wholeExercise2 = WorkoutDraft(workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])
    
    @State static var workout =  [wholeExercise1, wholeExercise2]
    
    @State static var workoutHint1 = WorkoutHints(repsHint: "100", weightHint: "100", intensityHint: "1", noteHint: "Note1")
    @State static var workoutHint2 = WorkoutHints(repsHint: "2", weightHint: "2", intensityHint: "2", noteHint: "Note2")
    @State static var workoutHints = [workoutHint1, workoutHint2]
    
    @State static var showToast = false
    @State static var toastMessage = ""
    
    static var previews: some View {
        WorkoutListView(workout: $workout, workoutHints: $workoutHints, workoutStateViewModel: WorkoutStateViewModel(), planName: "", routineName: "")
//        WorkoutListExerciseView(exercise: $wholeExercise2)
//        WorkoutListSeriesView(series: $series1_1, seriesCount: 0, position: 0)
    }
}
