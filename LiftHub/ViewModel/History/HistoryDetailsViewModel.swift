//
//  HistoryDetailsViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 22/11/2024.
//

import Foundation

class HistoryDetailsViewModel: ObservableObject {
    let historyElement: WorkoutHistoryElement
    @Published var workout: [WorkoutDraft] = []
    
    init(historyElement: WorkoutHistoryElement) {
        self.historyElement = historyElement
    }
    
    func loadHistoryDetails() {
        let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
        let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
        let exercises = workoutHistoryDatabaseHelper.getWorkoutExercises(date: historyElement.rawDate, routineName: historyElement.routineName, planName: historyElement.planName)
        for exercise in exercises {
            guard let exerciseId = workoutHistoryDatabaseHelper.getExerciseID(date: historyElement.rawDate, exerciseName: exercise.name) else {
                print("Exercise id was null in loading history details")
                return
            }
            let series = workoutSeriesDatabaseHelper.getSeries(exerciseId: exerciseId)
            workout.append(WorkoutDraft(workoutExerciseDraft: exercise, workoutSeriesDraftList: series))
        }
    }
}
