//
//  ValidationException.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import Foundation

class ValidationException: LocalizedError {
    let message: String
    let position: Int?
    init(message: String, position: Int? = nil) {
        self.message = message
        self.position = position
    }
    
    var errorDescription: String? {
        return message
    }
}
