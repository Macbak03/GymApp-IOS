//
//  WorkoutDraft.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 14/09/2024.
//

import Foundation

struct WorkoutDraft: Codable {
    let workoutExerciseDraft: WorkoutExerciseDraft
    let workoutSeriesDraftList: [WorkoutSeriesDraft]
}
