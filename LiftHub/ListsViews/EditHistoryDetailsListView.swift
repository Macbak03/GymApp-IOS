//
//  EditHistoryDetailsListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 17/09/2024.
//

import Foundation
import SwiftUI

struct EditHistoryDetailsListView: View {
    @Binding var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])]
    @Binding var showToast: Bool
    @Binding var toastMessage: String

    var body: some View {
        ScrollView {
            ForEach(workout.indices, id: \.self) {
                index in
                EditHistoryDetailsListExerciseView(exercise: $workout[index], position: index, showToast: $showToast, toastMessage: $toastMessage)
            }
        }
    }
}

private struct EditHistoryDetailsListExerciseView: View {
    @Binding var exercise: (workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])
    let position: Int
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    @State private var isDetailsVisible = false
    @State private var displayNote = false
    
    @State private var exerciseName = "Exercise"
    
    @State private var intensityIndexText = "Intensity"
    @State private var restValue = "val"
    @State private var restUnit = "val"
    @State private var seriesValue = "val"
    @State private var intensityValue = "val"
    @State private var paceValue = "val"
    
    @State private var noteHint = "Note"
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isDetailsVisible ? 0 : -90))
                .frame(width: 20, height: 20)
                .padding(.leading, 15)
            VStack(alignment: .leading, spacing: 5) {
                // First Horizontal Layout (Exercise Name)
                HStack {
                    Text(exerciseName)
                        .font(.system(size: 24, weight: .bold))  // Equivalent to bold and textSize 24sp
                        .frame(height: 20)  // Equivalent to layout_height="30dp"
                    //.padding(.leading, 35)  // Equivalent to layout_marginStart="35dp"
                    Spacer()  // To take up the remaining space
                }
                .frame(maxWidth: .infinity)
                
                // Second Horizontal Layout (Rest, Series, Intensity, Pace)
                HStack(alignment: .center) {
                    let VSpacing: CGFloat = 3
                    // Rest Layout
                    VStack(spacing: VSpacing) {
                        Text("Rest:")
                        HStack(spacing: 1) {
                            Text(restValue)
                                .frame(alignment: .trailing)
                            
                            Text(restUnit)
                                .frame(alignment: .leading)
                        }
                    }
                    Spacer()
                    // Series Layout
                    VStack(spacing: VSpacing) {
                        Text("Series:")
                        Text(seriesValue)
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    }
                    Spacer()
                    // Intensity Layout
                    VStack(spacing: VSpacing) {
                        Text(intensityIndexText)
                        Text(intensityValue)
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    }
                    Spacer()
                    // Pace Layout
                    VStack(spacing: VSpacing) {
                        Text("Pace:")
                        Text(paceValue)
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
                isDetailsVisible.toggle()
            }
        }
        .onAppear() {
            initValues(workoutExerciseDraft: exercise.workoutExerciseDraft)
        }
        Divider()
            .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
            .background(Color(.systemGray6)) // Set color for the line
        if isDetailsVisible {
            ForEach(exercise.workoutSeriesDraftList.indices, id: \.self) {
                index in
                HistoryDetailsListSeriesView(series: $exercise.workoutSeriesDraftList[index], seriesCount: exercise.workoutSeriesDraftList.count, position: index, showToast: $showToast, toastMessage: $toastMessage)
            }
            // Note Input
            TextField(noteHint, text: $exercise.workoutExerciseDraft.note)
                .font(.system(size: 21))
                .padding(.horizontal, 10) // Equivalent to layout_marginStart and layout_marginEnd
                .padding(.bottom, 10)  // Equivalent to layout_marginBottom
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Divider()
                .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
                .background(Color(.systemGray6)) // Set color for the line
        }
        
    }
    private func initValues(workoutExerciseDraft: WorkoutExerciseDraft) {
        self.exerciseName = workoutExerciseDraft.name
        self.intensityIndexText = workoutExerciseDraft.intensityIndex.rawValue
        self.restValue = workoutExerciseDraft.pause
        self.restUnit = workoutExerciseDraft.pauseUnit.rawValue
        self.seriesValue = workoutExerciseDraft.series
        self.intensityValue = workoutExerciseDraft.intensity
        self.paceValue = workoutExerciseDraft.pace
    }
}

private struct HistoryDetailsListSeriesView: View {
    @Binding var series: WorkoutSeriesDraft
    let seriesCount: Int
    let position: Int
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    
    @State private var repsHint: String = "Reps"
    @State private var weightHint: String = "Weight"
    @State private var intensityHint: String = "RPE"
    
    @State private var intensityIndexText: String = "RPE"
    @State private var weightUnitText: String = "kg"
    
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
                TextField(repsHint, text: $series.actualReps)
                    .keyboardType(.decimalPad)
                    .frame(height: 30)
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
                TextField(weightHint, text: $series.actualLoad)
                    .keyboardType(.decimalPad)
                    .frame(height: 30)
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
                TextField(intensityHint, text: $series.actualIntensity)
                    .keyboardType(.decimalPad)
                    .frame(width: 40,height: 30)
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
                    .padding(.trailing, 5)
                
            }
            .padding(.top, 5)  // Equivalent to layout_marginTop="5dp"
            .padding(.horizontal, 10)
        }
        .onAppear() {
            initValues(series: series)
        }
    }
    
    private func initValues(series: WorkoutSeriesDraft){
        self.weightUnitText = series.loadUnit.rawValue
        self.intensityIndexText = series.intensityIndex.rawValue
    }
    
    private func setToast(errorMessage: String) {
        toastMessage = errorMessage
        showToast = true
    }
    
    private func validateReps(focused: Bool) {
        if !focused {
            do {
                try _ = RepsFactory.fromString(series.actualReps)
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
                try _ = Weight.fromStringWithUnit(series.actualLoad, unit: series.loadUnit)
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
                try _ = IntensityFactory.fromStringForWorkout(series.actualIntensity, index: series.intensityIndex)
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

struct EditHistoryDetailsListView_previews: PreviewProvider {
    @State static var exercise1 = WorkoutExerciseDraft(name: "Exercise1", pause: "3-5", pauseUnit: TimeUnit.min, series: "1", reps: "1", intensity: "1", intensityIndex: IntensityIndex.RPE, pace: "1111", note: "note1")
    @State static var series1_1 = WorkoutSeriesDraft(actualReps: "11", actualLoad: "11", loadUnit: WeightUnit.kg, intensityIndex: IntensityIndex.RPE, actualIntensity: "1")
    
    @State static var wholeExercise1 = (workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1])
    
    @State static var exercise2 = WorkoutExerciseDraft(name: "Exercise2", pause: "2", pauseUnit: TimeUnit.s, series: "2", reps: "2", intensity: "2", intensityIndex: IntensityIndex.RIR, pace: "2222", note: "note2")
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
        EditHistoryDetailsListView(workout: $workout, showToast: $showToast, toastMessage: $toastMessage)
//        WorkoutListExerciseView(exercise: $wholeExercise2)
//        WorkoutListSeriesView(series: $series1_1, seriesCount: 0, position: 0)
    }
}

