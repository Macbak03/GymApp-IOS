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
    var body: some View {
        List {
            ForEach(viewModel.workoutDraft) {
                exercise in
                WorkoutListExerciseView(exercise: binding(for: exercise), viewModel: NoPlanWorkoutExerciseViewModel(exerciseCount: viewModel.workoutDraft.count), stateViewModel: stateViewModel, noPlanWorkoutViewModel: viewModel, exerciseRemoved: $exerciseRemoved)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if viewModel.workoutDraft.count > 1 {
                            Button(role: .destructive) {
                                exerciseRemoved.removed = true
                                exerciseRemoved.id = exercise.id
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    viewModel.removeExercise(id: exercise.id)
                                }
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
            }
        }
        .listStyle(PlainListStyle())
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
    
    @State var setAdded = false
    
    @Binding var exerciseRemoved: (removed: Bool, id: UUID?)
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isDetailsVisible ? 0 : -90))
                .frame(width: 20, height: 20)
                .padding(.leading, 10)
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
            Button(action: {
                addSet()
            }) {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 23, height: 23)
                    .padding(.trailing, 15)
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: 30, height: 30)
            .padding(.trailing, -10)
            
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
            List {
                ForEach(exercise.workoutSeriesDraftList) {
                    set in
                    WorkoutListSeriesView(set: binding(for: set), stateViewModel: stateViewModel, noPlanWorkoutViewModel: noPlanWorkoutViewModel, viewModel: NoPlanWorkoutSetViewModel(seriesCount: exercise.workoutSeriesDraftList.count))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if exercise.workoutSeriesDraftList.count > 1 {
                                Button(role: .destructive) {
                                    removeSet(id: set.id)
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
            TextField("Note", text: $exercise.workoutExerciseDraft.note)
                .font(.system(size: 16))
                .frame(height: 25)
                .padding(.horizontal, 15)
                .padding(.top, 2)
            
        }
            
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
    @ObservedObject var noPlanWorkoutViewModel: NoPlanWorkoutViewModel
    @StateObject var viewModel: NoPlanWorkoutSetViewModel
    
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
                // First Horizontal Layout for Series Count, Reps, Weight
                
                HStack(spacing: getSpacing(for: screenWidth)) {
                    // Series Count
                    Text("\(viewModel.seriesCount).")
                        .font(.system(size: textSize))
                        .padding(.leading, 10)
                        .frame(width: 30)
                    // Reps Input
                    TextField(viewModel.repsHint, text: $set.actualReps)
                        .keyboardType(.decimalPad)
                        .font(.system(size: textSize))
                        .frame(width: 40, height: outllineFrameHeight)
                        .multilineTextAlignment(.trailing)// Equivalent to textAlignment="textEnd"
                        .padding(.horizontal, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                .stroke((viewModel.showRepsError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                        )
                        .focused($isRepsFocused)
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
                    
                    // Multiplication Sign
                    Text("x")
                        .font(.system(size: textSize))
                        .frame(width: 10)
                        .multilineTextAlignment(.center)
                    
                    // Weight Input
                    TextField(viewModel.weightHint, text: $set.actualLoad)
                        .keyboardType(.decimalPad)
                        .font(.system(size: textSize))
                        .frame(width: 55, height: outllineFrameHeight)
                        .multilineTextAlignment(.leading)// Equivalent to textAlignment="textEnd"
                        .padding(.horizontal, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                .stroke((viewModel.showLoadError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                        )
                        .focused($isLoadFocused)
                        .onChange(of: isLoadFocused) { _, focused in
                            viewModel.validateLoad(focused: focused, set: set, stateViewModel: stateViewModel)
                            showLoadToolbar = focused
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
                    
                    Divider()
                        .frame(width: 2, height: 25)  // Vertical line, adjust height as needed
                        .background(Color(.systemGray6)) // Set color for the line
                    
                    // Intensity Value
                    Text("\(viewModel.intensityIndexText):")
                        .font(.system(size: textSize))
                    // Intensity Input
                    TextField(viewModel.intensityHint, text: $set.actualIntensity)
                        .keyboardType(.decimalPad)
                        .font(.system(size: textSize))
                        .frame(width: 35, height: outllineFrameHeight)
                        .multilineTextAlignment(.leading)// Equivalent to textAlignment="textEnd"
                        .padding(.horizontal, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: textFieldCornerRadius)
                                .stroke((viewModel.showIntensityError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                        )
                        .focused($isIntensityFocused)
                        .onChange(of: isIntensityFocused) { _, focused in
                            viewModel.validateIntensity(focused: focused, set: set, stateViewModel: stateViewModel)
                            showIntensityToolbar = focused
                        }
                        .toolbar {
                            if showIntensityToolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    CustomKeyboardToolbar(textFieldValue: $set.actualIntensity)
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
    @State static var exercise1 = WorkoutExerciseDraft(name: "Exercise1", pause: "3-5", pauseUnit: TimeUnit.min, series: "1", reps: "1", intensity: "1", intensityIndex: IntensityIndex.RPE, pace: "1111", note: "note1")
    @State static var series1_1 = WorkoutSeriesDraft(actualReps: "11", actualLoad: "11", loadUnit: WeightUnit.kg, intensityIndex: IntensityIndex.RPE, actualIntensity: "1")
    
    @State static var wholeExercise1 = WorkoutDraft(workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1])
    
    @State static var exercise2 = WorkoutExerciseDraft(name: "Exercise2", pause: "2", pauseUnit: TimeUnit.s, series: "2", reps: "2", intensity: "2", intensityIndex: IntensityIndex.RIR, pace: "2222", note: "note2")
    @State static var series2_1 = WorkoutSeriesDraft(actualReps: "21", actualLoad: "150.25", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "2")
    @State static var series2_2 = WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "")
    
    @State static var wholeExercise2 = WorkoutDraft(workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])
    
    @State static var workout =  [wholeExercise1, wholeExercise2]
    
    @State static var showToast = false
    @State static var toastMessage = ""
    
    static var previews: some View {
        NoPlanWorkoutListView(viewModel: NoPlanWorkoutViewModel(planName: "", date: "", intensityIndex: IntensityIndex.RPE, weightUnit: WeightUnit.kg), stateViewModel: WorkoutStateViewModel())
        //        WorkoutListExerciseView(exercise: $wholeExercise2)
        //        WorkoutListSeriesView(series: $series1_1, seriesCount: 0, position: 0)
    }
}

