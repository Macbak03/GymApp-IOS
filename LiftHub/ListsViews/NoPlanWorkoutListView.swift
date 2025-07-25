//
//  NoPlanWorkoutListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 19/09/2024.
//

import Foundation
import SwiftUI
import Combine
import SwiftUIIntrospect

struct NoPlanWorkoutListView: View {
    @ObservedObject var viewModel: NoPlanWorkoutViewModel
    @ObservedObject var stateViewModel: WorkoutStateViewModel
    
    @State private var exerciseRemoved: (removed: Bool, id: UUID?) = (removed: false, id: nil)
    @State private var isLastExercise: (last: Bool, id: UUID?) = (last: false, id: nil)
    var body: some View {
        List {
            ForEach(viewModel.workoutDraft) {
                exercise in
                WorkoutListExerciseView(
                    exercise: binding(for: exercise),
                    viewModel: NoPlanWorkoutExerciseViewModel(exerciseCount: viewModel.workoutDraft.count),
                    stateViewModel: stateViewModel,
                    noPlanWorkoutViewModel: viewModel,
                    exerciseRemoved: $exerciseRemoved,
                    isLastExercise: $isLastExercise)
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
}

private struct WorkoutListExerciseView: View {
    @Binding var exercise: WorkoutDraft
    @StateObject var viewModel: NoPlanWorkoutExerciseViewModel
    @ObservedObject var stateViewModel: WorkoutStateViewModel
    @ObservedObject var noPlanWorkoutViewModel: NoPlanWorkoutViewModel
    
    @State private var isDetailsVisible = false
    @State private var displayNote = false
    
    
    @FocusState private var isExerciseNameFocused: Bool
    
    @State private var setAdded = false
    @State private var workoutModified = false
    
    @Binding var exerciseRemoved: (removed: Bool, id: UUID?)
    @Binding var isLastExercise: (last: Bool, id: UUID?)
    
    private let textSize: CGFloat = 15
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isDetailsVisible ? 0 : -90))
                .frame(width: 20, height: 20)
                .onTapGesture {
                    withAnimation {
                        isDetailsVisible.toggle()
                    }
                }
            
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
                    viewModel.validateExerciseName(focused: focused, exercise: exercise.workoutExerciseDraft, stateViewModel: stateViewModel)
                }
            
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
            
            if isLastExercise.last && exercise.id == isLastExercise.id {
                Button(action: {
                    noPlanWorkoutViewModel.addExercise()
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(Color.accentColor)
                }
                .frame(width: 18, height: 25)
            }
            
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        
        .onChange(of: exerciseRemoved.removed) { _, removed in
            if removed && exerciseRemoved.id == exercise.id {
                isDetailsVisible = false
                exerciseRemoved.removed = false
            }
        }
        
        if isDetailsVisible {
            VStack {
                List {
                    ForEach(exercise.workoutSeriesDraftList.indices, id: \.self) {
                        index in
                        WorkoutListSeriesView(
                            set: $exercise.workoutSeriesDraftList[index],
                            stateViewModel: stateViewModel,
                            viewModel: NoPlanWorkoutSetViewModel(seriesCount: index + 1, exercsieType: exercise.workoutExerciseDraft.exerciseType),
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
                HStack {
                    Button(action: {
                        isDetailsVisible = true
                        addSet()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(.trailing, 5)
                            .foregroundStyle(Color.accentColor)
                    }
                    .frame(width: 30, height: 25)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                TextField("Note", text: $exercise.workoutExerciseDraft.note)
                    .font(.system(size: 16))
                    .frame(height: 25)
                    .padding(.horizontal, 20)
            }
            
            
            if exercise.workoutExerciseDraft.exerciseType != .timed {
                VStack{
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
                
            }
            
        }
        
    }
    
    private func calculateVolume() -> Double {
        var volumeValue = 0.0
        exercise.workoutSeriesDraftList.forEach { series in
            volumeValue += (Double(series.actualLoad) ?? 0.0) * (Double(series.actualReps) ?? 0.0)
        }
        
        return volumeValue
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
        let setDraft = WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: noPlanWorkoutViewModel.weightUnit, intensityIndex: noPlanWorkoutViewModel.intensityIndex, actualIntensity: "")
        exercise.workoutSeriesDraftList.append(setDraft)
        setAdded = true
    }
    
    private func removeSet(id: UUID) {
        if let index = exercise.workoutSeriesDraftList.firstIndex(where: { $0.id == id }) {
               exercise.workoutSeriesDraftList.remove(at: index)
           }
    }
    
    
    private func binding(for set: WorkoutSeriesDraft) -> Binding<WorkoutSeriesDraft> {
        guard let index = exercise.workoutSeriesDraftList.firstIndex(where: { $0.id == set.id }) else {
            fatalError("Cannot find set in array")
        }
        return $exercise.workoutSeriesDraftList[index]
    }
    
}

private struct WorkoutListSeriesView: View {
    @Binding var set: WorkoutSeriesDraft
    @ObservedObject var stateViewModel: WorkoutStateViewModel
    @StateObject var viewModel: NoPlanWorkoutSetViewModel
    @Binding var workoutModified: Bool
    
    @FocusState private var isLoadFocused: Bool
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isIntensityFocused: Bool
    
    @State private var showLoadToolbar = false
    @State private var showRepsToolbar = false
    @State private var showIntensityToolbar = false
    
    
    private let textFieldCornerRadius: CGFloat = 5
    private let textFieldStrokeLineWidth: CGFloat = 0.5
    
    private let textSize: CGFloat = 15
    private let outllineFrameHeight: CGFloat = 25
    
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            VStack(alignment: .leading) {

                HStack(spacing: getSpacing(for: screenWidth)) {
                    // Series Count
                    Text("\(viewModel.seriesCount).")
                        .font(.system(size: textSize))
                        //.padding(.leading, 10)
                        .frame(width: 30)
                    // Reps Input
                    TextField(viewModel.repsHint, text: $set.actualReps)
                        .keyboardType(.decimalPad)
                        .font(.system(size: textSize))
                        .frame(minWidth: 40, minHeight: outllineFrameHeight)
                        .multilineTextAlignment(.trailing)
                        .padding(.horizontal, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                .stroke((viewModel.showRepsError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                        )
                        .focused($isRepsFocused)
                        .onChange(of: set.actualReps) { _, _ in
                            workoutModified = true
                        }
                        .onChange(of: isRepsFocused) { _, focused in
                            viewModel.validateReps(focused: focused, set: set, stateViewModel: stateViewModel)
                            showRepsToolbar = focused
                        }
                        .toolbar {
                            if showRepsToolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    CustomKeyboardToolbar(textFieldValue: $set.actualReps)
                                }
                            }
                        }
                    
                    Text(viewModel.exerciseType == .timed ? "s" : "x")
                        .font(.system(size: textSize))
                        .frame(width: 10)
                        .multilineTextAlignment(.center)
                    
                    // Weight Input
                    TextField(viewModel.weightHint, text: $set.actualLoad)
                        .keyboardType(.decimalPad)
                        .font(.system(size: textSize))
                        .frame(minWidth: 55, minHeight: outllineFrameHeight)
                        .multilineTextAlignment(.leading)// Equivalent to textAlignment="textEnd"
                        .padding(.horizontal, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                .stroke((viewModel.showLoadError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                        )
                        .focused($isLoadFocused)
                        .onChange(of: set.actualLoad) { _, _ in
                            workoutModified = true
                        }
                        .onChange(of: isLoadFocused) { _, focused in
                            viewModel.validateLoad(focused: focused, set: set, stateViewModel: stateViewModel)
                            showLoadToolbar = focused
                        }
                        .onChange(of: viewModel.exerciseType) { _, type in
                            if viewModel.repsHint == "Reps" && type == .timed {
                                viewModel.repsHint = "Time"
                            } else {
                                viewModel.repsHint = "Reps"
                            }
                        }
                        .onAppear() {
                            if viewModel.repsHint == "Reps" && viewModel.exerciseType == .timed {
                                viewModel.repsHint = "Time"
                            } else {
                                viewModel.repsHint = "Reps"
                            }
                        }
                        .toolbar {
                            if showLoadToolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    CustomKeyboardToolbar(textFieldValue: $set.actualLoad)
                                }
                            }
                        }
                    
                    // Weight Unit Value
                    Text(viewModel.weightUnitText)  // Assuming the weight unit is kilograms
                        .font(.system(size: textSize))
                    
                    
                    if viewModel.exerciseType != .timed {
                        Divider()
                            .frame(width: 2, height: 25)  // Vertical line, adjust height as needed
                            .background(Color(.systemGray6)) // Set color for the line
                        
                        // Intensity Value
                        Text("\(viewModel.intensityIndexText):")
                            .font(.system(size: textSize))
                        // Intensity Input
                        TextField(viewModel.intensityHint, text: $viewModel.intensityValue)
                            .keyboardType(.decimalPad)
                            .font(.system(size: textSize))
                            .frame(minWidth: 35, minHeight: outllineFrameHeight)
                            .multilineTextAlignment(.leading)// Equivalent to textAlignment="textEnd"
                            .padding(.horizontal, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                    .stroke((viewModel.showIntensityError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                            )
                            .focused($isIntensityFocused)
                            .onChange(of: viewModel.intensityValue) { _, intensity in
                                set.actualIntensity = intensity
                            }
                            .onChange(of: isIntensityFocused) { _, focused in
                                viewModel.validateIntensity(focused: focused, set: set, stateViewModel: stateViewModel)
                                showIntensityToolbar = focused
                            }
                            .onChange(of: viewModel.exerciseType) { _, type in
                                if type == .timed {
                                    viewModel.intensityValue = ""
                                }
                            }
                            .toolbar {
                                if showIntensityToolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        CustomKeyboardToolbar(textFieldValue: $viewModel.intensityValue)
                                    }
                                }
                            }
                    }
                }
            }
            
            
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.top, 5)  // Equivalent to layout_marginTop="5dp"
        .padding(.horizontal, -15)
    }
    
    private func getSpacing(for screenWidth: CGFloat) -> CGFloat {
        // Adjust spacing to be smaller for smaller screen sizes
        if screenWidth < 380 {
            return 5  // iPhone SE size or smaller
        } else if screenWidth < 400 {
            return 10 // Mid-sized phones (e.g., iPhone 11, XR)
        } else {
            return 15 // Larger devices (e.g., iPhone Pro Max, iPads)
        }
    }
}

struct NoPlanWorkoutListView_previews: PreviewProvider {
    @State static var exercise1 = WorkoutExerciseDraft(name: "Exercise1", pause: "3-5", pauseUnit: TimeUnit.min, series: "1", reps: "1", loadUnit: WeightUnit.kg, intensity: "1", intensityIndex: IntensityIndex.RPE, pace: "1111", note: "note1")
    @State static var series1_1 = WorkoutSeriesDraft(actualReps: "11", actualLoad: "11", loadUnit: WeightUnit.kg, intensityIndex: IntensityIndex.RPE, actualIntensity: "1")
    
    @State static var wholeExercise1 = WorkoutDraft(workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1])
    
    @State static var exercise2 = WorkoutExerciseDraft(name: "Exercise2", pause: "2", pauseUnit: TimeUnit.s, series: "2", reps: "2", loadUnit: WeightUnit.lbs, intensity: "2", intensityIndex: IntensityIndex.RIR, pace: "2222", note: "note2")
    @State static var series2_1 = WorkoutSeriesDraft(actualReps: "21", actualLoad: "150.25", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "2")
    @State static var series2_2 = WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "")
    
    @State static var wholeExercise2 = WorkoutDraft(workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])
    
    @State static var workout =  [wholeExercise1, wholeExercise2]
    
    @State static var showToast = false
    @State static var toastMessage = ""
    
    static var previews: some View {
        NoPlanWorkoutListView(viewModel: NoPlanWorkoutViewModel(workoutDraft: workout, planName: "", date: "", intensityIndex: IntensityIndex.RPE, weightUnit: WeightUnit.kg), stateViewModel: WorkoutStateViewModel())
        //        WorkoutListExerciseView(exercise: $wholeExercise2)
        //        WorkoutListSeriesView(series: $series1_1, seriesCount: 0, position: 0)
    }
}

