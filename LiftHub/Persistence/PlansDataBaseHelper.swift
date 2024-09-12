//
//  PlansDatabaseHelper.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 08/09/2024.
//

import Foundation
import SQLite

class PlansDataBaseHelper: Repository {
    static let TABLE_NAME = "trainingPlans"
    static let ID_COLUMN = "planID"
    static let NAME_COLUMN = "planName"
    
    // Define table and columns
    private let plansTable = Table(TABLE_NAME)
    private let planId = Expression<Int64>(ID_COLUMN)
    private let planName = Expression<String>(NAME_COLUMN)
    
    func getPlans() -> [TrainingPlan] {
        var plans: [TrainingPlan] = []
        
        do {
            for plan in try db!.prepare(plansTable.select(planName)) {
                if let name = try? plan.get(planName) {
                    plans.append(TrainingPlan(name: name))
                }
            }
        } catch {
            print("Error retrieving plans: \(error)")
        }
        return plans
    }
    
    // Create the table if it doesn't exist
    override func createTableIfNotExists() {
        do {
            try db?.run(plansTable.create(ifNotExists: true) { table in
                table.column(planId, primaryKey: .autoincrement)
                table.column(planName, unique: true)
            })
        } catch {
            print("Error creating table: \(error)")
        }
    }
    
    // Add a new plan
    func addPlan(planName: String) {
        do {
            let insert = plansTable.insert(self.planName <- planName)
            try db?.run(insert)
            print("Plan added successfully")
        } catch {
            print("Error adding plan: \(error)")
        }
    }
    
    // Update plan name by plan ID
    func updatePlanName(planId: Int64, newName: String) {
        let planToUpdate = plansTable.filter(self.planId == planId)
        do {
            try db?.run(planToUpdate.update(self.planName <- newName))
            print("Plan updated successfully")
        } catch {
            print("Error updating plan: \(error)")
        }
    }
    
    // Delete plan by plan name
    func deletePlan(planName: String) {
        let planToDelete = plansTable.filter(self.planName == planName)
        do {
            try db?.run(planToDelete.delete())
            print("Plan deleted successfully")
        } catch {
            print("Error deleting plan: \(error)")
        }
    }
    
    // Check if a plan with the given name exists
    func doesPlanNameExist(planName: String) -> Bool {
        let query = plansTable.filter(self.planName == planName)
        do {
            let count = try db?.scalar(query.count) ?? 0
            return count > 0
        } catch {
            print("Error checking if plan exists: \(error)")
            return false
        }
    }
    
    // Get the plan ID by plan name
    func getPlanId(planName: String) -> Int64? {
        let query = plansTable.filter(self.planName == planName)
        
        do {
            let rows = try db?.prepare(query)
            
            // Check if any rows are returned and inspect them
            for row in rows! {
                print("Found Plan ID: \(row[self.planId]) for planName: \(row[self.planName])")
                return row[self.planId]
            }
            
            print("No record found for planName: \(planName)")
            
        } catch {
            print("Error fetching plan ID: \(error)")
        }
        
        return nil
    }

    
    // Check if the table is not empty
    func isTableNotEmpty() -> Bool {
        do {
            let count = try db?.scalar(plansTable.count) ?? 0
            return count > 0
        } catch {
            print("Error checking if table is empty: \(error)")
            return false
        }
    }
}

