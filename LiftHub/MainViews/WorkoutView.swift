//
//  WorkoutView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 13/09/2024.
//

import SwiftUI

struct WorkoutView: View {
    @Environment(\.presentationMode) var presentationMode // Allows us to dismiss this view
    
    @State private var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])] = []
    
    let planName: String
    let routineName: String
    
    var body: some View {
        GeometryReader { geometry  in
            VStack {
                // Back button as ZStack
                HStack {
                    ZStack{
                        HStack{
                            Button(action: {
                                // Dismiss the current view to go back
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            Spacer()
                        }
                        .padding(.leading, 30) // Add some padding to keep it away from the edge
                        
                        Text(routineName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.TextColorPrimary)
                    }
                }
                
                WorkoutListView(workout: $workout)
                
                // Horizontal layout for buttons
                HStack(spacing: 10) {
                    Button(action: {
                        // Cancel action
                    }) {
                        Text("Cancel Workout")
                            .frame(alignment: .center)
                    }
                    .frame(width: 140, height: 45)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    //                // Timer button with ZStack for the icon
                    //                ZStack {
                    //                    Button(action: {
                    //                        // Timer action
                    //                    }) {
                    //                        Image(systemName: "timer")
                    //                            .resizable()
                    //                            .frame(width: 35, height: 35)
                    //                    }
                    //                    .frame(width: 60, height: 54)
                    //                    .background(Color.black.opacity(0.7))
                    //                    .cornerRadius(8)
                    //                }
                    
                    Spacer()
                    
                    Button(action: {
                        // Save action
                    }) {
                        Text("Save Workout")                    }
                    .frame(width: 140, height: 45)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 32)
                .padding(.horizontal, 50)
                
                Spacer() // To push content up
                
                // Guideline equivalent (use a Spacer with fixed height)
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear(){
                loadRoutine()
            }
        }
    }
    
    private func loadRoutine() {
        let exercisesDatabaseHelper = ExercisesDataBaseHelper()
        let plansDatabaseHelper = PlansDataBaseHelper()
        guard let planId = plansDatabaseHelper.getPlanId(planName: planName) else {
            print("planId was null in workoutView")
            return
        }
        let savedRoutine = exercisesDatabaseHelper.getRoutine(routineName: routineName, planId: String(planId))
        for (index, savedExercise) in savedRoutine.enumerated() {
            let exercise = WorkoutExerciseDraft(name: savedExercise.name, pause: savedExercise.pause, pauseUnit: savedExercise.pauseUnit, series: savedExercise.series, reps: savedExercise.reps, intensity: savedExercise.intensity, intensityIndex: savedExercise.intensityIndex, pace: savedExercise.pace)
            let seriesList: [WorkoutSeriesDraft] = Array(repeating: WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: savedExercise.loadUnit, intensityIndex: savedExercise.intensityIndex, actualIntensity: ""), count: Int(savedExercise.series)!)
            workout.append((workoutExerciseDraft: exercise, workoutSeriesDraftList: seriesList))
        }
        
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(planName: "Plan", routineName: "Routine")
    }
}

