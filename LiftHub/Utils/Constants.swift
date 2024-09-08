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
