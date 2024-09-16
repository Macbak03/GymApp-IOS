//
//  HistoryDetailsView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 16/09/2024.
//

import SwiftUI

struct HistoryDetailsView: View {
    @Environment(\.presentationMode) var presentationMode // Allows us to dismiss this view
    @State private var workout: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])] = []
    let rawDate: String
    let date: String
    let planName: String
    let routineName: String

    var body: some View {
        VStack{
            ZStack {
                // Centered text on top of the screen
                VStack {
                    VStack {
                        Text(routineName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.primary)
                        Text(date)
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(Color.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                // Back button aligned to top-left
                HStack {
                    Button(action: {
                        // Dismiss the current view to go back
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .padding(.leading, 30)
                    .padding(.top, 10) // Adjust top padding as needed
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(height: 70)
            HistoryDetailsListView(workout: $workout)
        }
        .onAppear() {
            loadHistoryDetails()
        }
    }
    
    private func loadHistoryDetails() {
        let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
        let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
        let exercises = workoutHistoryDatabaseHelper.getWorkoutExercises(date: rawDate, routineName: routineName, planName: planName)
        for exercise in exercises {
            guard let exerciseId = workoutHistoryDatabaseHelper.getExerciseID(date: rawDate, exerciseName: exercise.name) else {
                print("Exercise id was null in loading history details")
                return
            }
            let series = workoutSeriesDatabaseHelper.getSeries(exerciseId: exerciseId)
            workout.append((workoutExerciseDraft: exercise, workoutSeriesDraftList: series))
        }
    }
}

struct HistoryDetailsView_Previews: PreviewProvider{
    static var previews: some View {
        HistoryDetailsView(rawDate: "16.09.2024 22:12:23", date: "16.09.2024", planName: "Plan", routineName: "Routine")
    }
}
