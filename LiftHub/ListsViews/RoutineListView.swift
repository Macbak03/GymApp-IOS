//
//  RoutineListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI

struct RoutineListView: View {
    @Binding var routine: [ExerciseDraft]
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    @Binding var descriptionType: DescriptionType?
    @Binding var alertType: AlertType?
    @Binding var wasExerciseModified: Bool
    
    var body: some View {
        List {
            ForEach(routine.indices, id: \.self) {
                index in
                ExerciseView(exercise: $routine[index], descriptionType: $descriptionType, alertType: $alertType, showToast: $showToast, toastMessage: $toastMessage, wasExerciseModified: $wasExerciseModified)
                
            }
            .onDelete(perform: { indexSet in
                deleteItem(atOffsets: indexSet)
            })
            .onMove(perform: { from, to in
                moveItem(from: from, to: to)
            })
        }
        .listStyle(PlainListStyle())
    }
    
    private func deleteItem(atOffsets: IndexSet) {
        routine.remove(atOffsets: atOffsets)
        wasExerciseModified = true
    }
    
    private func moveItem(from source: IndexSet, to destination: Int) {
        routine.move(fromOffsets: source, toOffset: destination)
    }
}

struct ExerciseView: View {
    @State private var isDetailsVisible: Bool = false
    @Binding var exercise: ExerciseDraft
    private let labelWidth: CGFloat = 50
    
    @FocusState private var isExerciseNameFocused: Bool
    @FocusState private var isPauseFocused: Bool
    @FocusState private var isLoadFocused: Bool
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isSeriesFocused: Bool
    @FocusState private var isIntensityFocused: Bool
    @FocusState private var isPaceFocused: Bool
    
    @State private var showNameError = false
    @State private var showPauseError = false
    @State private var showLoadError = false
    @State private var showRepsError = false
    @State private var showSeriesError = false
    @State private var showIntensityError = false
    @State private var showPaceError = false
    
    @Binding var descriptionType: DescriptionType?
    @Binding var alertType: AlertType?
    
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    @Binding var wasExerciseModified: Bool
    
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
                    
                    TextField("Exercise name", text: $exercise.name)
                        .font(.system(size: 18, weight: .bold))
                        .frame(height: 30)
                        .padding(.leading, 10)
                        .padding(.trailing, 20)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                        .overlay(Rectangle() // Add underline
                            .frame(height: 1) // Thickness of underline
                            .foregroundColor(showNameError ? .red : Color.TextUnderline) // Color of underline
                            .padding(.trailing, 37)
                            .padding(.leading, 10)
                            .padding(.top, 40),
                                 alignment: .bottom
                        )// Adjust underline position
                        .focused($isExerciseNameFocused)
                        .onChange(of: isExerciseNameFocused) { _, focused in
                            validateExerciseName(focused: focused)
                        }
                        .onChange(of: exercise.name) { _, _ in
                            if wasRoutineLoaded {
                                wasExerciseModified = true
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
                            TextField("eg. 3 or 3-5", text: $exercise.pause)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((showPauseError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isPauseFocused)
                                .onChange(of: isPauseFocused) { _, focused in
                                    validatePause(focused: focused)
                                    showPauseToolbar = focused
                                }
                                .onChange(of: exercise.pause) { _, _ in
                                    if wasRoutineLoaded {
                                        wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showPauseToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $exercise.pause)
                                        }
                                    }
                                }
                            
                            Picker("Rest", selection: $exercise.pauseUnit) {
                                ForEach(TimeUnit.allCases, id: \.self) { unit in
                                    Text(unit.descritpion).tag(unit)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 60, alignment: .trailing)
                            .onChange(of: exercise.pauseUnit) { _, _ in
                                if wasRoutineLoaded {
                                    wasExerciseModified = true
                                }
                            }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    descriptionType = .pause
                                    alertType = .description(DescriptionType.pause)
                                }
                        }
                        
                        // Load Section
                        HStack {
                            Text("Load")
                                .frame(width: labelWidth, alignment: .trailing)
                                .font(.system(size: textSize))
                            
                            TextField("eg. 30", text: $exercise.load)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((showLoadError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isLoadFocused)
                                .onChange(of: isLoadFocused) { _, focused in
                                    validateLoad(focused: focused)
                                    showLoadToolbar = focused
                                }
                                .onChange(of: exercise.load) { _, _ in
                                    if wasRoutineLoaded {
                                        wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showLoadToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $exercise.load)
                                        }
                                    }
                                }
                            
                            Picker("Load", selection: $exercise.loadUnit) {
                                ForEach(WeightUnit.allCases, id: \.self) { unit in
                                    Text(unit.descritpion).tag(unit)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 60, alignment: .trailing)
                            .onChange(of: exercise.loadUnit) { _, _ in
                                if wasRoutineLoaded {
                                    wasExerciseModified = true
                                }
                            }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    descriptionType = .load
                                    alertType = .description(DescriptionType.load)
                                    
                                }
                        }
                        
                        // Reps Section
                        HStack {
                            Text("Reps")
                                .frame(width: labelWidth, alignment: .trailing)
                                .font(.system(size: textSize))
                            TextField("eg. 6 or 6-8", text: $exercise.reps)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((showRepsError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isRepsFocused)
                                .onChange(of: isRepsFocused) {_,  focused in
                                    validateReps(focused: focused)
                                    showRepsToolbar = focused
                                }
                                .onChange(of: exercise.reps) { _, _ in
                                    if wasRoutineLoaded {
                                        wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showRepsToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $exercise.reps)
                                        }
                                    }
                                }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    descriptionType = .reps
                                    alertType = .description(DescriptionType.reps)
                                    
                                }
                        }
                        
                        // Series Section
                        HStack {
                            Text("Series")
                                .frame(width: labelWidth, alignment: .trailing)
                                .font(.system(size: textSize))
                            
                            TextField("eg. 3", text: $exercise.series)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((showSeriesError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isSeriesFocused)
                                .onChange(of: isSeriesFocused) { _, focused in
                                    validateSeries(focused: focused)
                                    showSeriesToolbar = focused
                                }
                                .onChange(of: exercise.series) { _, _ in
                                    if wasRoutineLoaded {
                                        wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showSeriesToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $exercise.series)
                                        }
                                    }
                                }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    descriptionType = .series
                                    alertType = .description(DescriptionType.series)
                                    
                                }
                            
                        }
                        
                        // Intensity Section
                        HStack {
                            Text(exercise.intensityIndex.descritpion)
                                .frame(width: labelWidth, alignment: .trailing)
                                .font(.system(size: textSize))
                            
                            TextField("eg. 5 or 5-6", text: $exercise.intensity)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((showIntensityError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isIntensityFocused)
                                .onChange(of: isIntensityFocused) { _, focused in
                                    validateIntensity(focused: focused)
                                    showIntensityToolbar = focused
                                }
                                .onChange(of: exercise.intensity) { _, _ in
                                    if wasRoutineLoaded {
                                        wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showIntensityToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $exercise.intensity)
                                        }
                                    }
                                }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    descriptionType = .intensity
                                    alertType = .description(DescriptionType.intensity)
                                    
                                }
                        }
                        
                        // Pace Section
                        HStack {
                            Text("Pace")
                                .frame(width: labelWidth, alignment: .trailing)
                                .font(.system(size: textSize))
                            
                            TextField("eg. 2110 or 21x0", text: $exercise.pace)
                                .keyboardType(.decimalPad)
                                .font(.system(size: textSize))
                                .padding(textFieldPadding)
                                .overlay(
                                    RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                        .stroke((showPaceError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                                )
                                .frame(maxWidth: .infinity)
                                .focused($isPaceFocused)
                                .onChange(of: isPaceFocused) { _, focused in
                                    validatePace(focused: focused)
                                    showPaceToolbar = focused
                                }
                                .onChange(of: exercise.pace) { _, _ in
                                    if wasRoutineLoaded {
                                        wasExerciseModified = true
                                    }
                                }
                                .toolbar {
                                    if showPaceToolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            CustomKeyboardToolbar(textFieldValue: $exercise.pace)
                                        }
                                    }
                                }
                            
                            Image(systemName: "info.circle")
                                .frame(width: descriptionImageFrameDimentions, height: descriptionImageFrameDimentions)
                                .onTapGesture {
                                    descriptionType = .pace
                                    alertType = .description(DescriptionType.pace)
                                    
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wasRoutineLoaded = true
            }
        }
    }
    
    private func setToast(errorMessage: String) {
        toastMessage = errorMessage
        showToast = true
    }
    
    private func handleExerciseNameException() throws {
        if exercise.name.isEmpty {
            throw ValidationException(message: "Exercise name cannot be empty")
        }
    }
    
    private func validateExerciseName(focused: Bool) {
        if !focused {
            do {
                try handleExerciseNameException()
            } catch let error as ValidationException {
                showNameError = true
                setToast(errorMessage: error.message)
            } catch {
                toastMessage = "An unexpected error occured \(error)"
            }
        } else {
            showNameError = false
        }
    }
    
    private func validatePause(focused: Bool) {
        if !focused {
            do {
                try _ = PauseFactory.fromString(exercise.pause, unit: exercise.pauseUnit)
            } catch let error as ValidationException {
                showPauseError = true
                setToast(errorMessage: error.message)
            } catch {
                toastMessage = "An unexpected error occured \(error)"
            }
        } else {
            showPauseError = false
        }
    }
    
    private func validateLoad(focused: Bool) {
        if !focused {
            do {
                try _ = Weight.fromStringWithUnit(exercise.load, unit: exercise.loadUnit)
            } catch let error as ValidationException {
                showLoadError = true
                setToast(errorMessage: error.message)
            } catch {
                toastMessage = "An unexpected error occured \(error)"
            }
        } else {
            showLoadError = false
        }
    }
    
    private func validateReps(focused: Bool) {
        if !focused {
            do {
                try _ = RepsFactory.fromString(exercise.reps)
            } catch let error as ValidationException {
                showRepsError = true
                setToast(errorMessage: error.message)
            } catch {
                toastMessage = "An unexpected error occured \(error)"
            }
        } else {
            showRepsError = false
        }
    }
    
    func handleSeriesException() throws {
        if exercise.series.isEmpty {
            throw ValidationException(message: "Series cannot be empty")
        }
        guard let _ = Int(exercise.series) else {
            throw ValidationException(message: "Series must be a number")
        }
    }
    
    func validateSeries(focused: Bool) {
        if !focused {
            do {
                try handleSeriesException()
            } catch let error as ValidationException {
                showSeriesError = true
                setToast(errorMessage: error.message)
            } catch {
                toastMessage = "An unexpected error occured \(error)"
            }
        } else {
            showSeriesError = false
        }
    }
    
    func validateIntensity(focused: Bool) {
        if !focused {
            do {
                try _ = IntensityFactory.fromString(exercise.intensity, index: exercise.intensityIndex)
            } catch let error as ValidationException {
                showIntensityError = true
                setToast(errorMessage: error.message)
            } catch {
                toastMessage = "An unexpected error occured \(error)"
            }
        } else {
            showIntensityError = false
        }
    }
    
    func validatePace(focused: Bool) {
        if !focused {
            do {
                try _ = ExercisePace.fromString(exercise.pace)
            } catch let error as ValidationException {
                showPaceError = true
                setToast(errorMessage: error.message)
            } catch {
                toastMessage = "An unexpected error occured \(error)"
            }
        } else {
            showPaceError = false
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
        RoutineListView(routine: $routine, showToast: $showToast, toastMessage: $toastMessage, descriptionType: $descriptionType, alertType: $alertType, wasExerciseModified: $showError)
    }
}


