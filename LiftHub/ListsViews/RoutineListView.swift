//
//  RoutineListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI

struct RoutineListView: View {
    @ObservedObject var viewModel: RoutineDetailsViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.routineDraft) {
                exercise in
                ExerciseView(viewModel: ExerciseViewModel(exerciseDraft: exercise), routineDetailsViewModel: viewModel)
                
            }
            .onDelete(perform: { indexSet in
                if routineIsUsedInCurrentWorkout() && !indexSet.contains(viewModel.routineDraft.count - 1) {
                    viewModel.setToast(message: "You can't delete exercises when you're in middle of workout")
                } else {
                    viewModel.deleteItem(atOffsets: indexSet)
                }
            })
            
            .onMove(perform: { from, to in
                if routineIsUsedInCurrentWorkout() {
                    viewModel.setToast(message: "You can't move exercises when you're in middle of workout")
                } else {
                    viewModel.moveItem(from: from, to: to)
                }
            })
        }
        .listStyle(PlainListStyle())
    }
    
    private func routineIsUsedInCurrentWorkout() -> Bool{
        if viewModel.planName == UserDefaultsUtils.shared.getSelectedPlan() && viewModel.routineName == UserDefaultsUtils.shared.getUnfinishedRoutineName() {
            return true
        }
        return false
    }
    
}

struct ExerciseView: View {
    @StateObject var viewModel: ExerciseViewModel
    @ObservedObject var routineDetailsViewModel: RoutineDetailsViewModel
    @State private var isDetailsVisible: Bool = false
    private let labelWidth: CGFloat = 50
    
    @FocusState private var isExerciseNameFocused: Bool
    @FocusState private var isPauseFocused: Bool
    @FocusState private var isLoadFocused: Bool
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isSeriesFocused: Bool
    @FocusState private var isIntensityFocused: Bool
    @FocusState private var isPaceFocused: Bool
    
    private let textFieldCornerRadius: CGFloat = 5
    private let textFieldPadding: CGFloat = 6
    private let textFieldStrokeLineWidth: CGFloat = 0.5
    
    private let descriptionImageFrameDimentions: CGFloat = 30
    
    private let textSize: CGFloat = 15
    
    @State private var showPauseToolbar = false
    @State private var showLoadToolbar = false
    @State private var showRepsToolbar = false
    @State private var showSeriesToolbar = false
    @State private var showIntensityToolbar = false
    @State private var showPaceToolbar = false
    
    @State private var wasRoutineLoaded = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 10) {
                // Title Section
                HStack {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isDetailsVisible ? 0 : -90))
                        .frame(width: 25, height: 25)
                        .onTapGesture {
                            withAnimation {
                                isDetailsVisible.toggle()
                            }
                        }
                    
                    TextField("Exercise name", text: $viewModel.exerciseDraft.name)
                        .font(.system(size: 18, weight: .bold))
                        .frame(height: 30)
                        .padding(.leading, 10)
                        .padding(.trailing, 20)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                        .overlay(Rectangle() // Add underline
                            .frame(height: 1) // Thickness of underline
                            .foregroundColor(viewModel.showNameError ? .red : Color.TextUnderline) // Color of underline
                            .padding(.trailing, 37)
                            .padding(.leading, 10)
                            .padding(.top, 40),
                                 alignment: .bottom
                        )// Adjust underline position
                        .focused($isExerciseNameFocused)
                        .onChange(of: isExerciseNameFocused) { _, focused in
                            viewModel.validateExerciseName(focused: focused, viewModel: routineDetailsViewModel)
                        }
                        .onChange(of: viewModel.exerciseDraft.name) { _, _ in
                            if wasRoutineLoaded {
                                routineDetailsViewModel.wasExerciseModified = true
                            }
                        }
                    
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                
                // Details Section (Toggleable)
                if isDetailsVisible {
                    VStack(spacing: 10) {
                        // Pause Section
                        HStack {
                            Text("Rest")
                                .frame(width: labelWidth, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: textSize))
                            TextField("eg. 3 or 3-5", text: $viewModel.exerciseDraft.pause)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((viewModel.showPauseError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isPauseFocused)
                                .onChange(of: isPauseFocused) { _, focused in
                                    viewModel.validatePause(focused: focused, viewModel: routineDetailsViewModel)
                                    showPauseToolbar = focused
                                }
                                .onChange(of: viewModel.exerciseDraft.pause) { _, _ in
                                    if wasRoutineLoaded {
                                        routineDetailsViewModel.wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showPauseToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $viewModel.exerciseDraft.pause)
                                        }
                                    }
                                }
                            
                            Picker("Rest", selection: $viewModel.exerciseDraft.pauseUnit) {
                                ForEach(TimeUnit.allCases, id: \.self) { unit in
                                    Text(unit.descritpion).tag(unit)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 60, alignment: .trailing)
                            .onChange(of: viewModel.exerciseDraft.pauseUnit) { _, _ in
                                if wasRoutineLoaded {
                                    routineDetailsViewModel.wasExerciseModified = true
                                }
                            }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    routineDetailsViewModel.descriptionType = .pause
                                    routineDetailsViewModel.alertType = .description(DescriptionType.pause)
                                }
                        }
                        
                        // Load Section
                        HStack {
                            Text("Load")
                                .frame(width: labelWidth, alignment: .trailing)
                                .font(.system(size: textSize))
                            
                            TextField("eg. 30", text: $viewModel.exerciseDraft.load)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((viewModel.showLoadError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isLoadFocused)
                                .onChange(of: isLoadFocused) { _, focused in
                                    viewModel.validateLoad(focused: focused, viewModel: routineDetailsViewModel)
                                    showLoadToolbar = focused
                                }
                                .onChange(of: viewModel.exerciseDraft.load) { _, _ in
                                    if wasRoutineLoaded {
                                        routineDetailsViewModel.wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showLoadToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $viewModel.exerciseDraft.load)
                                        }
                                    }
                                }
                            
                            Picker("Load", selection: $viewModel.exerciseDraft.loadUnit) {
                                ForEach(WeightUnit.allCases, id: \.self) { unit in
                                    Text(unit.descritpion).tag(unit)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 60, alignment: .trailing)
                            .onChange(of: viewModel.exerciseDraft.loadUnit) { _, _ in
                                if wasRoutineLoaded {
                                    routineDetailsViewModel.wasExerciseModified = true
                                }
                            }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    routineDetailsViewModel.descriptionType = .load
                                    routineDetailsViewModel.alertType = .description(DescriptionType.load)
                                    
                                }
                        }
                        
                        // Reps Section
                        HStack {
                            Text("Reps")
                                .frame(width: labelWidth, alignment: .trailing)
                                .font(.system(size: textSize))
                            TextField("eg. 6 or 6-8", text: $viewModel.exerciseDraft.reps)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((viewModel.showRepsError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isRepsFocused)
                                .onChange(of: isRepsFocused) {_,  focused in
                                    viewModel.validateReps(focused: focused, viewModel: routineDetailsViewModel)
                                    showRepsToolbar = focused
                                }
                                .onChange(of: viewModel.exerciseDraft.reps) { _, _ in
                                    if wasRoutineLoaded {
                                        routineDetailsViewModel.wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showRepsToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $viewModel.exerciseDraft.reps)
                                        }
                                    }
                                }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    routineDetailsViewModel.descriptionType = .reps
                                    routineDetailsViewModel.alertType = .description(DescriptionType.reps)
                                    
                                }
                        }
                        
                        // Series Section
                        HStack {
                            Text("Series")
                                .frame(width: labelWidth, alignment: .trailing)
                                .font(.system(size: textSize))
                            
                            TextField("eg. 3", text: $viewModel.exerciseDraft.series)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((viewModel.showSeriesError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isSeriesFocused)
                                .onChange(of: isSeriesFocused) { _, focused in
                                    viewModel.validateSeries(focused: focused, viewModel: routineDetailsViewModel)
                                    showSeriesToolbar = focused
                                }
                                .onChange(of: viewModel.exerciseDraft.series) { _, _ in
                                    if wasRoutineLoaded {
                                        routineDetailsViewModel.wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showSeriesToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $viewModel.exerciseDraft.series)
                                        }
                                    }
                                }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    routineDetailsViewModel.descriptionType = .series
                                    routineDetailsViewModel.alertType = .description(DescriptionType.series)
                                    
                                }
                            
                        }
                        
                        // Intensity Section
                        HStack {
                            Text(viewModel.exerciseDraft.intensityIndex.descritpion)
                                .frame(width: labelWidth, alignment: .trailing)
                                .font(.system(size: textSize))
                            
                            TextField("eg. 5 or 5-6", text: $viewModel.exerciseDraft.intensity)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((viewModel.showIntensityError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isIntensityFocused)
                                .onChange(of: isIntensityFocused) { _, focused in
                                    viewModel.validateIntensity(focused: focused, viewModel: routineDetailsViewModel)
                                    showIntensityToolbar = focused
                                }
                                .onChange(of: viewModel.exerciseDraft.intensity) { _, _ in
                                    if wasRoutineLoaded {
                                        routineDetailsViewModel.wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showIntensityToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $viewModel.exerciseDraft.intensity)
                                        }
                                    }
                                }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    routineDetailsViewModel.descriptionType = .intensity
                                    routineDetailsViewModel.alertType = .description(DescriptionType.intensity)
                                    
                                }
                        }
                        
                        // Pace Section
                        HStack {
                            Text("Pace")
                                .frame(width: labelWidth, alignment: .trailing)
                                .font(.system(size: textSize))
                            
                            TextField("eg. 2110 or 21x0", text: $viewModel.exerciseDraft.pace)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((viewModel.showPaceError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isPaceFocused)
                                .onChange(of: isPaceFocused) { _, focused in
                                    viewModel.validatePace(focused: focused, viewModel: routineDetailsViewModel)
                                    showPaceToolbar = focused
                                }
                                .onChange(of: viewModel.exerciseDraft.pace) { _, _ in
                                    if wasRoutineLoaded {
                                        routineDetailsViewModel.wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showPaceToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $viewModel.exerciseDraft.pace)
                                        }
                                    }
                                }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    routineDetailsViewModel.descriptionType = .pace
                                    routineDetailsViewModel.alertType = .description(DescriptionType.pace)
                                    
                                }
                        }
                    }
                    .transition(.opacity)
                }
            }
            //.padding(.horizontal)
            .animation(.easeInOut, value: isDetailsVisible)
        }
        .onAppear {
            //viewModel.initExercise(exerciseDraft: exercise)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wasRoutineLoaded = true
            }
        }
    }
    
}

struct RoutineListView_Previews: PreviewProvider {
    private static let exercise1 = ExerciseDraft(name: "Exercise1", pause: "3", pauseUnit: TimeUnit.min, load: "30", loadUnit: WeightUnit.kg, series: "3", reps: "8", intensity: "9", intensityIndex: IntensityIndex.RPE, pace: "2111", wasModified: false)
    private static let exercise2 = ExerciseDraft(name: "Exercise2", pause: "1", pauseUnit: TimeUnit.s, load: "10", loadUnit: WeightUnit.lbs, series: "2", reps: "6", intensity: "8", intensityIndex: IntensityIndex.RIR, pace: "21x0", wasModified: false)
    @State static var routine: [ExerciseDraft] = [exercise1, exercise2]
    @State static var showToast = false
    @State static var showError = false
    @State static var toastMessage = ""
    @State static var descriptionType: DescriptionType? = DescriptionType.pace
    @State static var alertType: AlertType? = AlertType.description(descriptionType!)
    static var previews: some View {
        RoutineListView(viewModel: RoutineDetailsViewModel())
    }
}


