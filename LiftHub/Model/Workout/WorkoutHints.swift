//
//  WorkoutHints.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 14/09/2024.
//

import Foundation

struct WorkoutHints: Codable, Identifiable, Hashable {
    var id = UUID()
    var repsHint: String
    var weightHint: String
    var intensityHint: String?
    var noteHint: String
    
    init(repsHint: String, weightHint: String, intensityHint: String?, noteHint: String) {
        self.repsHint = repsHint
        self.weightHint = weightHint
        self.intensityHint = intensityHint
        self.noteHint = noteHint
    }
}
