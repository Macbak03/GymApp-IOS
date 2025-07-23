//
//  Repository.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 11/09/2024.
//

import Foundation
import SQLite

// Base Repository class to be inherited by other database classes
class Repository {
    
    static let DATABASE_NAME = "GymApp.sqlite3"
    
    var db: Connection?
    
    // Initialize the database connection
    init() {
        do {
            let dbPath = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent(Repository.DATABASE_NAME)
                .path
            
            db = try Connection(dbPath)
            try onConfigure()
            try createTableIfNotExists()
            print(dbPath)

        } catch {
            print("Error initializing database: \(error)")
        }
    }
    
    // Enable foreign key support
    private func onConfigure() throws {
        try db?.execute("PRAGMA foreign_keys = ON;")
    }
    
    open func createTableIfNotExists() throws {
        fatalError("Subclasses must override createTableIfNotExists")
    }
    
}
