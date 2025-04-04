//
//  Constants.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//

import Foundation

class Constants {
    public static let DARK_MODE = "DARK_MODE"
    public static let LIGHT_MODE = "LIGHT_MODE"
    
    public static let IS_WORKOUT_SAVED_KEY = "IsWorkoutUnsaved"
    public static let UNFINISHED_WORKOUT_ROUTINE_NAME = "UnfinishedRoutineName"
    public static let SELECTED_PLAN_NAME = "SelectedPlanName"
    public static let UNFINISHED_PLAN_NAME = "UnfinishedPlanName"
    public static let DATE = "WorkoutDate"
    
    public static let NO_PLAN_NAME = "No training plan"
    
    public static let HAS_WORKOUT_ENDED = "hasWorkoutEnded"
}

enum DialogState {
    case edit
    case add
    
    func description() -> String {
        switch self {
        case .edit:
            return "Edit plan"
        case .add:
            return "Add plan"
        }
    }
}
