//
//  WorkoutListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 13/09/2024.
//

import Foundation
import SwiftUI

struct WorkoutListView: View {
    @Binding var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])]
    @State private var isExpanded = false
    var body: some View {
        ScrollView {
            ForEach(workout.indices, id: \.self) {
                index in
                WorkoutListExerciseView(exercise: $workout[index])
            }
        }
    }
}

private struct WorkoutListExerciseView: View {
    @State private var isDetailsVisible = false
    @State private var displayNote = false
    @Binding var exercise: (workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])
    
    @State private var exerciseName = "Exercise"
    
    @State private var intensityIndexText = "Intensity"
    @State private var restValue = "val"
    @State private var restUnit = "val"
    @State private var seriesValue = "val"
    @State private var intensityValue = "val"
    @State private var paceValue = "val"
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isDetailsVisible ? 0 : -90))
                .frame(width: 20, height: 20)
                .padding(.leading, 15)
                .onTapGesture {
                    withAnimation {
                        isDetailsVisible.toggle()
                    }
                }
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
                HStack(alignment: .center, spacing: 45) {
                    let VSpacing: CGFloat = 3
                    let maxWidth: CGFloat = 40
                    let maxHeight: CGFloat = 20
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
                    
                    // Series Layout
                    VStack(spacing: VSpacing) {
                        Text("Series:")
                        Text(seriesValue)
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    }
                    
                    // Intensity Layout
                    VStack(spacing: VSpacing) {
                        Text(intensityIndexText)
                        Text(intensityValue)
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    }
                    
                    // Pace Layout
                    VStack(spacing: VSpacing) {
                        Text("Pace:")
                        Text(paceValue)
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 15)  // General padding for the whole view
        }
        .onAppear() {
            let exerciseMainValues = exercise.workoutExerciseDraft
            initValues(exerciseName: exerciseMainValues.name, intensityIndexText: exerciseMainValues.intensityIndex.rawValue, restValue: exerciseMainValues.pause, restUnit: exerciseMainValues.pauseUnit.rawValue, seriesValue: exerciseMainValues.series, intensityIndexValue: exerciseMainValues.intensity, paceValue: exerciseMainValues.pace)
        }
        Divider()
            .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
            .background(Color(.systemGray6)) // Set color for the line
        if isDetailsVisible {
            ForEach(exercise.workoutSeriesDraftList.indices, id: \.self) {
                index in
                WorkoutListSeriesView(series: $exercise.workoutSeriesDraftList[index], seriesCount: exercise.workoutSeriesDraftList.count, position: index)
            }
        }
    }
    private func initValues(exerciseName: String, intensityIndexText: String, restValue: String, restUnit: String, seriesValue: String, intensityIndexValue: String, paceValue: String) {
        self.exerciseName = exerciseName
        self.intensityIndexText = intensityIndexText
        self.restValue = restValue
        self.restUnit = restUnit
        self.seriesValue = seriesValue
        self.intensityValue = intensityIndexValue
        self.paceValue = paceValue
    }
}

private struct WorkoutListSeriesView: View {
    @Binding var series: WorkoutSeriesDraft
    let seriesCount: Int
    let position: Int
    @State private var reps: String = ""
    @State private var weight: String = ""
    @State private var note: String = ""
    @State private var intensity: String = ""
    
    @State private var intensityIndexText: String = "RPE"
    @State private var weightUnitText: String = "kg"
    
    var body: some View {
        VStack(alignment: .leading) {
            // First Horizontal Layout for Series Count, Reps, Weight
            HStack(spacing: 5) {
                // Series Count
                Text("1.")
                    .font(.system(size: 18))
                    .padding(.leading, 4) // Equivalent to layout_marginStart="10dp"
                
                // Reps Input
                TextField("Reps", text: $reps)
                    .keyboardType(.decimalPad)
                    .frame(height: 50)
                    .multilineTextAlignment(.trailing) // Equivalent to textAlignment="textEnd"
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Multiplication Sign
                Text("x")
                    .font(.system(size: 18))
                    .frame(width: 20)
                    .multilineTextAlignment(.center)
                
                // Weight Input
                TextField("Weight", text: $weight)
                    .keyboardType(.decimalPad)
                    .frame(height: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Weight Unit Value
                Text(weightUnitText)  // Assuming the weight unit is kilograms
                    .font(.system(size: 18))
                
                Divider()
                    .frame(width: 2, height: 35)  // Vertical line, adjust height as needed
                    .background(Color(.systemGray6)) // Set color for the line
                
                // Weight Unit Value
                Text("\(intensityIndexText):")  // Assuming the weight unit is kilograms
                    .font(.system(size: 18))
                // Weight Input
                TextField(intensityIndexText, text: $intensity)
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: 50, maxHeight: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing, 5)
                
            }
            .padding(.top, 5)  // Equivalent to layout_marginTop="5dp"
            .padding(.horizontal, 10)
            
            // Note Input
            if position == seriesCount - 1 {
                TextField("Note", text: $note)
                    .font(.system(size: 21))
                    .padding(.horizontal, 10) // Equivalent to layout_marginStart and layout_marginEnd
                    .padding(.bottom, 10)  // Equivalent to layout_marginBottom
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .onAppear() {
            initValues(weightUnitText: series.loadUnit.rawValue, intensityIndexText: series.intensityIndex.rawValue)
        }
        Divider()
            .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
            .background(Color(.systemGray6)) // Set color for the line
    }
    
    private func initValues(weightUnitText: String, intensityIndexText: String){
        self.weightUnitText = weightUnitText
        self.intensityIndexText = intensityIndexText
    }
}

struct WorkoutListView_previews: PreviewProvider {
    @State static var exercise1 = WorkoutExerciseDraft(name: "Exercise", pause: "1", pauseUnit: TimeUnit.min, series: "1", reps: "1", intensity: "1", intensityIndex: IntensityIndex.RPE, pace: "1111")
    @State static var series1_1 = WorkoutSeriesDraft(actualReps: "11", actualLoad: "11", loadUnit: WeightUnit.kg, intensityIndex: IntensityIndex.RPE, actualIntensity: "1")
    
    @State static var wholeExercise1 = (workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1])
    
    @State static var exercise2 = WorkoutExerciseDraft(name: "Exercise", pause: "2", pauseUnit: TimeUnit.s, series: "2", reps: "2", intensity: "2", intensityIndex: IntensityIndex.RIR, pace: "2222")
    @State static var series2_1 = WorkoutSeriesDraft(actualReps: "21", actualLoad: "21", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "2")
    @State static var series2_2 = WorkoutSeriesDraft(actualReps: "22", actualLoad: "22", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "3")
    
    @State static var wholeExercise2 = (workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])
    
    @State static var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])] =  [(workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1]), (workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])]
    static var previews: some View {
        WorkoutListView(workout: $workout)
        WorkoutListExerciseView(exercise: $wholeExercise2)
        WorkoutListSeriesView(series: $series1_1, seriesCount: 0, position: 0)
    }
}
