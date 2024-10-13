//
//  NoPlanWorkoutListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 19/09/2024.
//

import Foundation
import SwiftUI

struct NoPlanWorkoutListView: View {
    @Binding var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])]
    
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    let intensityIndex: IntensityIndex
    let weightUnit: WeightUnit

    var body: some View {
        ScrollView {
            ForEach(workout.indices, id: \.self) {
                index in
                WorkoutListExerciseView(workout: $workout, exercise: $workout[index], position: index, exerciseCount: workout.count, showToast: $showToast, toastMessage: $toastMessage, intensityIndex: intensityIndex, weightUnit: weightUnit)
            }
        }
    }
}

private struct WorkoutListExerciseView: View {
    @Binding var workout:  [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])]
    @Binding var exercise: (workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])
    let position: Int
    let exerciseCount: Int
    
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    let intensityIndex: IntensityIndex
    let weightUnit: WeightUnit
    
    @State private var isDetailsVisible = true
    @State private var displayNote = false
    @State private var showNameError = false
    
    @FocusState private var isExerciseNameFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isDetailsVisible ? 0 : -90))
                .frame(width: 40, height: 40)
                .onTapGesture {
                    withAnimation {
                        isDetailsVisible.toggle()
                    }
                }
            
            TextField("Exercise name", text: $exercise.workoutExerciseDraft.name)
                .font(.system(size: 22, weight: .bold))
                .frame(height: 40)
                .padding(.leading, 10)
                .padding(.trailing, 20)
                .lineLimit(1)
                .truncationMode(.tail)
            
                .overlay(Rectangle() // Add underline
                    .frame(height: 1) // Thickness of underline
                    .foregroundColor(showNameError ? .red : Color.TextUnderline) // Color of underline
                    .padding(.trailing, exerciseCount == 1 ? 65 : 20)
                    .padding(.leading, 10)
                    .padding(.top, 40),
                         alignment: .bottom
                )// Adjust underline position
                .focused($isExerciseNameFocused)
                .onChange(of: isExerciseNameFocused) { focused in
                    validateExerciseName(focused: focused)
                }
            
            
            if exerciseCount > 1 {
                Button(action: {
                    removeExercise()
                }) {
                    Image(systemName: "minus.circle")
                        .resizable()  // Enable image resizing
                        .frame(width: 23, height: 23)
                        .padding(.trailing, 15)
                }
                .frame(width: 30, height: 40)
                .padding(.trailing, exerciseCount != position + 1 ? 10:0)
                .padding(.leading, exerciseCount != position + 1 ? 45: 0)
            }
            
            if exerciseCount == position + 1 {
                Button(action: {
                    addExercise()
                }) {
                    Image(systemName: "plus.circle")
                        .resizable()  // Enable image resizing
                        .frame(width: 23, height: 23)
                        .padding(.trailing, 15)
                }
                .frame(width: 30, height: 40)
                .padding(.trailing, 10)
            }

        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        Divider()
            .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
            .background(Color(.systemGray6)) // Set color for the line
        if isDetailsVisible {
            ForEach(exercise.workoutSeriesDraftList.indices, id: \.self) {
                index in
                WorkoutListSeriesView(sets: $exercise.workoutSeriesDraftList, set: $exercise.workoutSeriesDraftList[index], seriesCount: exercise.workoutSeriesDraftList.count, position: index, showToast: $showToast, toastMessage: $toastMessage, intensityIndex: intensityIndex, weightUnit: weightUnit)
            }
            // Note Input
            TextField("Note", text: $exercise.workoutExerciseDraft.note)
                .font(.system(size: 21))
                .padding(.horizontal, 10) // Equivalent to layout_marginStart and layout_marginEnd
                .padding(.bottom, 10)  // Equivalent to layout_marginBottom
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Divider()
                .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
                .background(Color(.systemGray6)) // Set color for the line
        }
        
    }
    
    private func handleExerciseNameException() throws {
        if exercise.workoutExerciseDraft.name.isEmpty {
            throw ValidationException(message: "Exercise name cannot be empty")
        }
    }
    
    private func validateExerciseName(focused: Bool) {
        if !focused {
            do {
                try handleExerciseNameException()
            } catch let error as ValidationException {
                showNameError = true
                showToast = true
                toastMessage = error.message
            } catch {
                toastMessage = "An unexpected error occured \(error)"
            }
        } else {
            showNameError = false
        }
    }
    
    private func addExercise() {
        let exerciseDraft = WorkoutExerciseDraft(name: "", pause: "0", pauseUnit: TimeUnit.min, series: "0", reps: "0", intensity: "0", intensityIndex: intensityIndex, pace: "0000", note: "")
        let exerciseSetDraft = WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: weightUnit, intensityIndex: intensityIndex, actualIntensity: "")
        workout.append((workoutExerciseDraft: exerciseDraft, workoutSeriesDraftList: [exerciseSetDraft]))
    }
    private func removeExercise() {
        workout.remove(at: position)
    }
}

private struct WorkoutListSeriesView: View {
    @Binding var sets: [WorkoutSeriesDraft]
    @Binding var set: WorkoutSeriesDraft
    let seriesCount: Int
    let position: Int
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    let intensityIndex: IntensityIndex
    let weightUnit: WeightUnit
    
    @State private var repsHint: String = "Reps"
    @State private var weightHint: String = "Weight"
    @State private var intensityHint: String = UserDefaultsUtils.shared.getIntensity()
    
    @State private var intensityIndexText: String = UserDefaultsUtils.shared.getIntensity()
    @State private var weightUnitText: String = UserDefaultsUtils.shared.getWeight()
    
    @State private var showLoadError = false
    @State private var showRepsError = false
    @State private var showIntensityError = false
    
    @FocusState private var isLoadFocused: Bool
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isIntensityFocused: Bool


    private let textFieldCornerRadius: CGFloat = 5
    private let textFieldStrokeLineWidth: CGFloat = 0.5
    
    var body: some View {
        VStack(alignment: .leading) {
            // First Horizontal Layout for Series Count, Reps, Weight
            HStack(spacing: 5) {
                // Series Count
                Text("\(position + 1).")
                    .font(.system(size: 18))
                    .padding(.leading, 4) // Equivalent to layout_marginStart="10dp"
                
                // Reps Input
                TextField(repsHint, text: $set.actualReps)
                    .keyboardType(.decimalPad)
                    .frame(width: 40, height: 30)
                    .multilineTextAlignment(.trailing)// Equivalent to textAlignment="textEnd"
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: textFieldCornerRadius)
                            .stroke((showRepsError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                    )
                    .focused($isRepsFocused)
                    .onChange(of: isRepsFocused) { focused in
                        validateReps(focused: focused)
                    }
                
                // Multiplication Sign
                Text("x")
                    .font(.system(size: 18))
                    .frame(width: 20)
                    .multilineTextAlignment(.center)
                
                // Weight Input
                TextField(weightHint, text: $set.actualLoad)
                    .keyboardType(.decimalPad)
                    .frame(width: 55, height: 30)
                    .multilineTextAlignment(.leading)// Equivalent to textAlignment="textEnd"
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: textFieldCornerRadius)
                            .stroke((showLoadError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                    )
                    .focused($isLoadFocused)
                    .onChange(of: isLoadFocused) { focused in
                        validateLoad(focused: focused)
                    }
                
                // Weight Unit Value
                Text(weightUnitText)  // Assuming the weight unit is kilograms
                    .font(.system(size: 18))
                
                Divider()
                    .frame(width: 2, height: 35)  // Vertical line, adjust height as needed
                    .background(Color(.systemGray6)) // Set color for the line
                
                // Intensity Value
                Text("\(intensityIndexText):")
                    .font(.system(size: 18))
                // Intensity Input
                TextField(intensityHint, text: $set.actualIntensity)
                    .keyboardType(.decimalPad)
                    .frame(width: 35,height: 30)
                    .multilineTextAlignment(.leading)// Equivalent to textAlignment="textEnd"
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: textFieldCornerRadius)
                            .stroke((showIntensityError ? Color.red : Color.textFieldOutline), lineWidth: textFieldStrokeLineWidth)
                    )
                    .focused($isIntensityFocused)
                    .onChange(of: isIntensityFocused) { focused in
                        validateIntensity(focused: focused)
                    }
//                    .toolbar {
//                        ToolbarItemGroup(placement: .keyboard) {
//                            Button(action: {
//                                // Add '-' to the input if not already present
//                                if !set.actualIntensity.contains("-") {
//                                    set.actualIntensity = "-" + set.actualIntensity
//                                }
//                            }) {
//                                Text("-")
//                            }
//                            
//                            Button(action: {
//                                // Add '.' to the input if not already present
//                                if !set.actualIntensity.contains(".") {
//                                    set.actualIntensity += "."
//                                }
//                            }) {
//                                Text(".")
//                            }
//                            
//                            Spacer()
//                        }
//                    }
                
                if seriesCount > 1 {
                    Button(action: {
                        addSet()
                    }) {
                        Image(systemName: "minus.circle")
                            .resizable()  // Enable image resizing
                            .frame(width: 20, height: 20)
                    }
                    .frame(width: 20, height: 40)
                    .padding(.leading, position > 0 ? 0 : 25)
                }
                
                if seriesCount == position + 1 {
                    Button(action: {
                        addSet()
                    }) {
                        Image(systemName: "plus.circle")
                            .resizable()  // Enable image resizing
                            .frame(width: 20, height: 20)
                    }
                    .frame(width: 20, height: 40)
                    .padding(.leading, position > 0 ? 0 : 25)
                }
                
            }
            .padding(.top, 5)  // Equivalent to layout_marginTop="5dp"
            .padding(.horizontal, 10)
        }
    }
    
    private func addSet() {
        let setDraft = WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: weightUnit, intensityIndex: intensityIndex, actualIntensity: "")
        sets.append(setDraft)
    }
    
    private func setToast(errorMessage: String) {
        toastMessage = errorMessage
        showToast = true
    }
    
    private func validateReps(focused: Bool) {
        if !focused {
            do {
                try _ = RepsFactory.fromString(set.actualReps)
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
    
    private func validateLoad(focused: Bool) {
        if !focused {
            do {
                try _ = Weight.fromStringWithUnit(set.actualLoad, unit: set.loadUnit)
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
    
    func validateIntensity(focused: Bool) {
        if !focused {
            do {
                try _ = IntensityFactory.fromStringForWorkout(set.actualIntensity, index: set.intensityIndex)
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
}

struct NoPlanWorkoutListView_previews: PreviewProvider {
    @State static var exercise1 = WorkoutExerciseDraft(name: "Exercise1", pause: "3-5", pauseUnit: TimeUnit.min, series: "1", reps: "1", intensity: "1", intensityIndex: IntensityIndex.RPE, pace: "1111", note: "note1")
    @State static var series1_1 = WorkoutSeriesDraft(actualReps: "11", actualLoad: "11", loadUnit: WeightUnit.kg, intensityIndex: IntensityIndex.RPE, actualIntensity: "1")
    
    @State static var wholeExercise1 = (workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1])
    
    @State static var exercise2 = WorkoutExerciseDraft(name: "Exercise2", pause: "2", pauseUnit: TimeUnit.s, series: "2", reps: "2", intensity: "2", intensityIndex: IntensityIndex.RIR, pace: "2222", note: "note2")
    @State static var series2_1 = WorkoutSeriesDraft(actualReps: "21", actualLoad: "150.25", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "2")
    @State static var series2_2 = WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "")
    
    @State static var wholeExercise2 = (workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])
    
    @State static var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])] =  [(workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1]), (workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])]
    
    @State static var showToast = false
    @State static var toastMessage = ""
    
    static var previews: some View {
        NoPlanWorkoutListView(workout: $workout, showToast: $showToast, toastMessage: $toastMessage, intensityIndex: IntensityIndex.RPE, weightUnit: WeightUnit.kg)
//        WorkoutListExerciseView(exercise: $wholeExercise2)
//        WorkoutListSeriesView(series: $series1_1, seriesCount: 0, position: 0)
    }
}

