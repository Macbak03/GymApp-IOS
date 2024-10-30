//
//  RoutinesDataBaseHelper.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 11/09/2024.
//

import Foundation
import SQLite

class RoutinesDataBaseHelper: Repository {
    static let TABLE_NAME = "routines"
    static let PLAN_ID_COLUMN = "planID"
    static let ROUTINE_ID_COLUMN = "routineID"
    static let ROUTINE_NAME_COLUMN = "routineName"
    
    // Define table and columns
    private let routinesTable = Table(TABLE_NAME)
    private let planId = Expression<Int64>(PLAN_ID_COLUMN)
    private let routineId = Expression<Int64>(ROUTINE_ID_COLUMN)
    private let routineName = Expression<String>(ROUTINE_NAME_COLUMN)
    
    private let plansTable = Table(PlansDataBaseHelper.TABLE_NAME)
    private let plansTableId = Expression<Int64>(PlansDataBaseHelper.ID_COLUMN)
    
    
    // Create the table if it doesn't exist
    override func createTableIfNotExists() {
        do {
            try db?.run(routinesTable.create(ifNotExists: true) { table in
                table.column(planId)
                table.column(routineId, primaryKey: .autoincrement)
                table.column(routineName)
                table.foreignKey(planId, references: plansTable, plansTableId, update: .cascade, delete: .cascade)
            })
        } catch {
            print("Error creating table: \(error)")
        }
    }
    
    // Function to delete routines by plan ID and list of routine names
    func deleteRoutine(planID: Int64, routineName: String) {
        do {
            let query = routinesTable.filter(self.planId == planID && self.routineName == routineName)
            try db?.run(query.delete())
            print("Succesfully deleted routine: \(routineName)")
        } catch {
            print("Error deleting routines: \(error)")
        }
    }

    // Function to fetch routines in a plan
    func getRoutinesInPlan(planId: Int64) -> [TrainingPlanElement] {
        var routines: [TrainingPlanElement] = []

        do {
            let query = routinesTable.select(routineName)
                .filter(self.planId == planId)
                .order(routineId)
            
            for routine in try db!.prepare(query) {
                if let name = try? routine.get(self.routineName) {
                    routines.append(TrainingPlanElement(name: name))
                }
            }
        } catch {
            print("Error retrieving routines: \(error)")
        }
        
        return routines
    }

    // Check if a plan contains any routines
    func isPlanNotEmpty(planId: Int64) -> Bool {
        do {
            let query = routinesTable.filter(self.planId == planId)
            return try db?.scalar(query.count) ?? 0 > 0
        } catch {
            print("Error checking if plan is empty: \(error)")
            return false
        }
    }
}

