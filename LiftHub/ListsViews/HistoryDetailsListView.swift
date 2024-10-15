//
//  HistoryDetailsListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 17/09/2024.
//

import SwiftUI

struct HistoryDetailsListView: View {
    @Binding var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])]
    let planName: String
    
    @State private var isExpanded = false
    var body: some View {
        ScrollView {
            ForEach(workout.indices, id: \.self) {
                index in
                HistoryDetailsListExerciseView(exercise: $workout[index], planName: planName)
            }
        }
    }
}

private struct HistoryDetailsListExerciseView: View {
    @Binding var exercise: (workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])
    let planName: String
    
    @State private var isDetailsVisible = false
    @State private var displayNote = false
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isDetailsVisible ? 0 : -90))
                .frame(width: 20, height: 20)
                .padding(.leading, 15)
            VStack(alignment: .leading, spacing: 5) {
                // First Horizontal Layout (Exercise Name)
                HStack {
                    Text(exercise.workoutExerciseDraft.name)
                        .font(.system(size: 24, weight: .bold))  // Equivalent to bold and textSize 24sp
                        .frame(height: 20)  // Equivalent to layout_height="30dp"
                    //.padding(.leading, 35)  // Equivalent to layout_marginStart="35dp"
                    Spacer()  // To take up the remaining space
                }
                .frame(maxWidth: .infinity)
                
                if planName != Constants.NO_PLAN_NAME {
                    
                    // Second Horizontal Layout (Rest, Series, Intensity, Pace)
                    HStack(alignment: .center) {
                        let VSpacing: CGFloat = 3
                        
                        // Rest Layout
                        VStack(spacing: VSpacing) {
                            Text("Rest:")
                            HStack(spacing: 1) {
                                Text(exercise.workoutExerciseDraft.pause)
                                    .frame(alignment: .trailing)
                                
                                Text(exercise.workoutExerciseDraft.pauseUnit.rawValue)
                                    .frame(alignment: .leading)
                            }
                        }
                        Spacer()
                        
                        // Series Layout
                        VStack(spacing: VSpacing) {
                            Text("Series:")
                            Text(exercise.workoutExerciseDraft.series)
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                        }
                        Spacer()
                        
                        // Intensity Layout
                        VStack(spacing: VSpacing) {
                            Text(exercise.workoutExerciseDraft.intensityIndex.rawValue)
                            Text(exercise.workoutExerciseDraft.intensity)
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                        }
                        Spacer()
                        
                        // Pace Layout
                        VStack(spacing: VSpacing) {
                            Text("Pace:")
                            Text(exercise.workoutExerciseDraft.pace)
                            //.frame(maxWidth: maxWidth, maxHeight: maxHeight)
                        }
                    }
                    .frame(maxWidth: .infinity, idealHeight: 100)
                    .padding(.horizontal, 15)
                }
            }
            .frame(height: (planName != Constants.NO_PLAN_NAME) ? 70 : 35)
            .padding(.horizontal, 15)  // General padding for the whole view
        }
        .onTapGesture {
            withAnimation {
                isDetailsVisible.toggle()
            }
        }
        Divider()
            .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
            .background(Color(.systemGray6)) // Set color for the line
        if isDetailsVisible {
            ForEach(exercise.workoutSeriesDraftList.indices, id: \.self) {
                index in
                HistoryDetailsListSeriesView(series: $exercise.workoutSeriesDraftList[index], position: index)
            }
            // Note Input
            if(!exercise.workoutExerciseDraft.note.isEmpty){
                Text(exercise.workoutExerciseDraft.note)
                    .font(.system(size: 21))
                    .padding(.leading, 15)
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)// Equivalent to layout_marginBottom
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider()
                .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
                .background(Color(.systemGray6)) // Set color for the line
        }
        
    }
}

private struct HistoryDetailsListSeriesView: View {
    @Binding var series: WorkoutSeriesDraft
    let position: Int
    
    var body: some View {
        // First Horizontal Layout for Series Count, Reps, Weight
        ZStack {
            // First HStack for Series Count on the left
            HStack {
                Text("\(position + 1).")
                    .font(.system(size: 18))
                    .padding(.leading, 4)
                Spacer() // Pushes the text to the left
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Second HStack for Reps, x, Weight, and LoadUnit in the center
            HStack(spacing: 2) {
                Text(series.actualReps)
                    .frame(height: 30)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 2)
                
                Text("x")
                    .font(.system(size: 18))
                    .frame(width: 10)
                    .multilineTextAlignment(.center)
                
                Text(series.actualLoad)
                    .frame(height: 30)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 2)
                
                Text(series.loadUnit.rawValue)
                    .font(.system(size: 18))
            }
            .frame(maxWidth: .infinity, alignment: .center) // Center the HStack
            .padding(.horizontal, 85)
            
            // Third HStack for Intensity Value on the right
            HStack {
                Divider()
                    .frame(width: 2, height: 35)  // Vertical line, adjust height as needed
                    .background(Color(.systemGray6)) // Set color for the line
                    .padding(.trailing, 5)
                
                Text("\(series.intensityIndex.rawValue):")
                    .font(.system(size: 18))
                
                Text(series.actualIntensity)
                    .frame(width: 25, height: 30)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 5)
            }
            .frame(maxWidth: .infinity, alignment: .trailing) // Align the HStack to the right
        }
        .padding(.top, 5)  // Equivalent to layout_marginTop="5dp"
        .padding(.horizontal, 10)
    }
}

struct HistoryDetailsListView_previews: PreviewProvider {
    @State static var exercise1 = WorkoutExerciseDraft(name: "Exercise1", pause: "1", pauseUnit: TimeUnit.min, series: "1", reps: "1", intensity: "1", intensityIndex: IntensityIndex.RPE, pace: "1111", note: "note1")
    @State static var series1_1 = WorkoutSeriesDraft(actualReps: "11", actualLoad: "11", loadUnit: WeightUnit.kg, intensityIndex: IntensityIndex.RPE, actualIntensity: "1")
    
    @State static var wholeExercise1 = (workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1])
    
    @State static var exercise2 = WorkoutExerciseDraft(name: "Exercise2", pause: "2", pauseUnit: TimeUnit.s, series: "2", reps: "2", intensity: "2", intensityIndex: IntensityIndex.RIR, pace: "2222", note: "note2")
    @State static var series2_1 = WorkoutSeriesDraft(actualReps: "21", actualLoad: "21", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "2")
    @State static var series2_2 = WorkoutSeriesDraft(actualReps: "22", actualLoad: "222", loadUnit: WeightUnit.lbs, intensityIndex: IntensityIndex.RIR, actualIntensity: "3")
    
    @State static var wholeExercise2 = (workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])
    
    @State static var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])] =  [(workoutExerciseDraft: exercise1, workoutSeriesDraftList: [series1_1]), (workoutExerciseDraft: exercise2, workoutSeriesDraftList: [series2_1, series2_2])]
    
    @State static var workoutHint1 = WorkoutHints(repsHint: "1", weightHint: "1", intensityHint: "1", noteHint: "Note1")
    @State static var workoutHint2 = WorkoutHints(repsHint: "2", weightHint: "2", intensityHint: "2", noteHint: "Note2")
    @State static var workoutHints = [workoutHint1, workoutHint2]
    
    @State static var showToast = false
    @State static var toastMessage = ""
    
    static var previews: some View {
        HistoryDetailsListView(workout: $workout, planName: Constants.NO_PLAN_NAME)
    }
}

