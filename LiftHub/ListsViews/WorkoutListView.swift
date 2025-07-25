//
//  WorkoutListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 13/09/2024.
//
import Foundation
import SwiftUI
import SwiftUIIntrospect
import Combine

struct WorkoutListView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @ObservedObject var workoutStateViewModel: WorkoutStateViewModel
    @State private var exerciseRemoved: (removed: Bool, id: UUID?) = (removed: false, id: nil)
    @State private var isLastExercise: (last: Bool, id: UUID?) = (last: false, id: nil)

    var body: some View {
        List {
            ForEach(viewModel.workoutDraft) {
                exercise in
                WorkoutListExerciseView(
                    exercise: binding(for: exercise),
                    workoutHints: hintsBinding(for: exercise),
                    workoutViewModel: viewModel,
                    workoutStateViewModel: workoutStateViewModel,
                    planName: viewModel.planName,
                    routineName: viewModel.routineName,
                    exerciseRemoved: $exerciseRemoved,
                    isLastExercise: $isLastExercise
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if viewModel.workoutDraft.count > 1 {
                        Button(role: .destructive) {
                            exerciseRemoved.removed = true
                            exerciseRemoved.id = exercise.id
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                viewModel.removeExercise(id: exercise.id)
                                updateLastExercise()
                            }
                        } label: {
                            Text("Delete")
                        }
                    }
                }
                .onAppear() {
                    updateLastExercise()
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func resetLastExercise() {
        if isLastExercise.id != nil {
            isLastExercise.id = nil
            isLastExercise.last = false
        }
    }
    
    private func setLastExercise() {
        let lastIndex = viewModel.workoutDraft.endIndex - 1
        if viewModel.workoutDraft[lastIndex].id != isLastExercise.id {
            isLastExercise.id = viewModel.workoutDraft[lastIndex].id
            isLastExercise.last = true
        }
    }
    
    private func updateLastExercise() {
        resetLastExercise()
        setLastExercise()
    }
    
    private func binding(for exercise: WorkoutDraft) -> Binding<WorkoutDraft> {
        guard let index = viewModel.workoutDraft.firstIndex(where: { $0.id == exercise.id }) else {
            fatalError("Cannot find exercise in array")
        }
        return $viewModel.workoutDraft[index]
    }
    
    private func hintsBinding(for exercise: WorkoutDraft) -> Binding<WorkoutHints> {
        guard let index = viewModel.workoutDraft.firstIndex(where: { $0.id == exercise.id }) else {
            fatalError("Cannot find hints in array")
        }
        return $viewModel.workoutHints[index]
    }
}

private struct WorkoutListExerciseView: View {
    @Binding var exercise: WorkoutDraft
    @Binding var workoutHints: WorkoutHints
    
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @ObservedObject var workoutStateViewModel: WorkoutStateViewModel
    @StateObject private var viewModel =  WorkoutExerciseViewModel()
    
    let planName: String
    let routineName: String
    
    @Binding var exerciseRemoved: (removed: Bool, id: UUID?)
    @Binding var isLastExercise: (last: Bool, id: UUID?)
    
    @State private var displayNote = false
    @State private var setAdded = false
    
    private let textSize: CGFloat = 15
    private let outllineFrameHeight: CGFloat = 30
    
    @State private var isSaveClicked = false
    
    @State private var defaultSetComparison = WorkoutHints(repsHint: "reps", weightHint: UserDefaultsUtils.shared.getWeightUnit(),  intensityHint: UserDefaultsUtils.shared.getIntensity(), noteHint: "note")
    @State private var workoutModified = false
    @FocusState private var isExerciseNameFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(viewModel.areDetailsVisible ? 0 : -90))
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        withAnimation {
                            viewModel.areDetailsVisible.toggle()
                        }
                    }
                VStack(alignment: .leading, spacing: 3) {
                    // First Horizontal Layout (Exercise Name)
                    HStack {
                        if !exercise.workoutExerciseDraft.isAdded {
                            Text(viewModel.exerciseName)
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .allowsTightening(true)
                        } else {
                            TextField("Exercise name", text: $exercise.workoutExerciseDraft.name)
                                .font(.system(size: 18, weight: .bold))
                                .frame(height: 30)
                                .padding(.leading, 3)
                                .padding(.trailing, 20)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .minimumScaleFactor(0.5)
                                .allowsTightening(true)
                            
                                .overlay(Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(viewModel.showNameError ? .red : Color.TextUnderline)
                                    .padding(.trailing, 20)
                                    .padding(.leading, 1)
                                    .padding(.top, 40),
                                         alignment: .bottom
                                )
                                .focused($isExerciseNameFocused)
                                .onChange(of: isExerciseNameFocused) { _, focused in
                                    viewModel.validateExerciseName(
                                        focused: focused,
                                        exercise: exercise.workoutExerciseDraft,
                                        stateViewModel: workoutStateViewModel)
                                }
                        }
                        Spacer()
                    }
                    
                    if !exercise.workoutExerciseDraft.isAdded && exercise.workoutExerciseDraft.pause != "0" && exercise.workoutExerciseDraft.pace != "0000" {
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
                }
                .padding(.horizontal, 10)  // General padding for the whole view
                if exercise.workoutExerciseDraft.isAdded {
                    Menu {
                        Picker(selection: $exercise.workoutExerciseDraft.exerciseType) {
                            ForEach(ExerciseType.allCases, id: \.self) { type in
                                Text(type.description).tag(type)
                            }
                        } label: {}
                    } label: {
                        HStack {
                            switch exercise.workoutExerciseDraft.exerciseType {
                            case .weighted:
                                Image(systemName: "dumbbell")
                                    .font(.system(size: textSize))
                                    .foregroundStyle(Color.Accent)
                            case .timed:
                                Image(systemName: "clock")
                                    .font(.system(size: textSize))
                                    .foregroundStyle(Color.Accent)
                            }
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: textSize))
                                .foregroundStyle(Color.Accent)
                        }
                    }
                    .frame(width: 40, alignment: .trailing)
                }
                
                if isLastExercise.last && exercise.id == isLastExercise.id {
                    Button(action: {
                        workoutViewModel.addExercise()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(Color.accentColor)
                    }
                    .frame(width: 18, height: 25)
                    .buttonStyle(.borderless)
                    .id("addExercise-\(exercise.id)")
                }
                
            }
            .onAppear() {
                viewModel.initValues(workoutExerciseDraft: exercise.workoutExerciseDraft, workoutHints: workoutHints)
                viewModel.loadLastWorkoutComparison(planName: planName, routineName: routineName)
            }
            .onChange(of: exerciseRemoved.removed) { _, removed in
                if removed && exerciseRemoved.id == exercise.id {
                    viewModel.areDetailsVisible = false
                    exerciseRemoved.removed = false
                }
            }
            .onChange(of: workoutStateViewModel.isSaveClicked) { _, clicked in
                if clicked {
                    viewModel.areDetailsVisible = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                        isSaveClicked = true
                    }
                }
            }
//            Divider()
//                .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
//                .background(Color(.systemGray6)) // Set color for the line
            if viewModel.areDetailsVisible {
                if !exercise.workoutExerciseDraft.isAdded {
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
                }
                List {
                    ForEach(exercise.workoutSeriesDraftList.indices, id: \.self) { index in
                        WorkoutListSeriesView(
                            series: $exercise.workoutSeriesDraftList[index],
                            workoutHint: $workoutHints,
                            setComparison: setComparisonBinding(index: index),
                            stateViewModel: workoutStateViewModel,
                            viewModel: WorkoutSeriesViewModel(
                                seriesCount: exercise.workoutSeriesDraftList.count,
                                position: index
                            ),
                            exerciseType: $exercise.workoutExerciseDraft.exerciseType,
                            isSaveClicked: $isSaveClicked,
                            selectedComparisonMethod: $viewModel.selectedComparingMethod,
                            workoutModified: $workoutModified
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if exercise.workoutSeriesDraftList.count > 1 {
                                Button(role: .destructive) {
                                    removeSet(id: exercise.workoutSeriesDraftList[index].id)
                                } label: {
                                    Text("Delete")
                                }
                            }
                        }
                    }
                }
                .frame(height: calculateListHeight(for: exercise.workoutSeriesDraftList.count))
                .listStyle(PlainListStyle())
                .introspect(.list, on: .iOS(.v17, .v18), customize: { list in
                    if setAdded {
                        DispatchQueue.main.async {
                            let lastIndex = IndexPath(item: self.exercise.workoutSeriesDraftList.count - 1, section: 0)
                            if self.exercise.workoutSeriesDraftList.count > 0 {
                                list.scrollToItem(at: lastIndex, at: .bottom, animated: true)
                                setAdded = false
                            }
                        }
                    }
                }) //it's responsible for scrolling the list to the bottom
                
                // Note Input
                HStack {
                    Button(action: {
                        addSet()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(.trailing, 5)
                            .foregroundStyle(Color.accentColor)
                    }
                    .frame(width: 30, height: 25)
                    .buttonStyle(.borderless)
                    .id("addSet-\(exercise.id)")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
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
                            if exercise.workoutExerciseDraft.isAdded {
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
                
//                Divider()
//                    .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
//                    .background(Color(.systemGray6)) // Set color for the line
            }
        }
    }

    
    private func setComparisonBinding(index: Int) -> Binding<WorkoutHints> {
        if index < viewModel.lastWorkoutComparison.count {
            return $viewModel.lastWorkoutComparison[index]
        } else {
            return $defaultSetComparison
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
    
    private func calculateListHeight(for itemCount: Int) -> CGFloat {
        let maxVisibleItems = 5
        let rowHeight: CGFloat = 40
        
        if itemCount <= maxVisibleItems {
            return CGFloat(itemCount) * rowHeight
        } else {
            return CGFloat(maxVisibleItems) * rowHeight
        }
    }
    
    private func addSet() {
        let setDraft = WorkoutSeriesDraft(
            actualReps: "",
            actualLoad: "",
            loadUnit: workoutViewModel.weightUnit,
            intensityIndex: workoutViewModel.intensityIndex,
            actualIntensity: exercise.workoutExerciseDraft.exerciseType == .timed ? nil : "")
        exercise.workoutSeriesDraftList.append(setDraft)
        setAdded = true
    }
    
    private func removeSet(id: UUID) {
        if let index = exercise.workoutSeriesDraftList.firstIndex(where: { $0.id == id }) {
               exercise.workoutSeriesDraftList.remove(at: index)
           }
    }
}

private struct WorkoutListSeriesView: View {
    @Binding var series: WorkoutSeriesDraft
    @Binding var workoutHint: WorkoutHints
    @Binding var setComparison: WorkoutHints
    @ObservedObject var stateViewModel: WorkoutStateViewModel
    @StateObject var viewModel: WorkoutSeriesViewModel
    
    @Binding var exerciseType: ExerciseType
    
    @Binding var isSaveClicked: Bool
    
    @Binding var selectedComparisonMethod: SelectedComparingMethod
    
    @Binding var workoutModified: Bool
    
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
                    .onChange(of: exerciseType) { _, type in
                        if viewModel.repsHint == "reps" && type == .timed {
                            viewModel.repsHint = "time"
                        } else {
                            viewModel.repsHint = "reps"
                        }
                    }
                    .toolbar {
                        if showRepsToolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                CustomKeyboardToolbar(textFieldValue: $series.actualReps)
                            }
                        }
                    }
                    .onAppear() {
                        if viewModel.repsHint == "reps" && exerciseType == .timed {
                            viewModel.repsHint = "time"
                        }
                    }
                
                
                Text(exerciseType == .timed ? "s" : "x")
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
                if series.actualIntensity != nil && exerciseType != .timed && viewModel.intensityHint != nil {
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
        WorkoutListView(viewModel: WorkoutViewModel(workoutDraft: workout, planName: "", routineName: "", date: "", intensityIndex: .RPE, weightUnit: .kg), workoutStateViewModel: WorkoutStateViewModel())
//        WorkoutListExerciseView(exercise: $wholeExercise2)
//        WorkoutListSeriesView(series: $series1_1, seriesCount: 0, position: 0)
    }
}
