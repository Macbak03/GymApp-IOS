//
//  PlansViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 21/11/2024.
//

import Foundation

class PlansViewModel: ObservableObject {
    @Published var trainingPlans: [TrainingPlan] = []
    
    private let plansDatabaseHelper = PlansDataBaseHelper()
    
    func loadPlans() {
        trainingPlans = plansDatabaseHelper.getPlans()
    }
    
    func addPlan(planName: String) throws {
        if planName.isEmpty {
            throw ValidationException(message: "Plan's name cannot be empty")
        }
        
        if trainingPlans.contains(where: { $0.name == planName }) {
            throw ValidationException(message: "A plan with this name already exists")
        }
        
        plansDatabaseHelper.addPlan(planName: planName)
        trainingPlans.append(TrainingPlan(name: planName))
    }
    
    func editPlan(planName: String?, planNameText: String, position: Int?) throws {
        guard let planName = planName else {
            throw ValidationException(message: "Plan's name was found null when editing plan")
        }
        if planNameText.isEmpty {
            throw ValidationException(message: "Plan's name cannot be empty")
        }
        if trainingPlans.contains(where: { $0.name == planNameText }) {
            throw ValidationException(message: "A plan with this name already exists")
        }
        let planId = plansDatabaseHelper.getPlanId(planName: planName)
        guard let checkedPlanId = planId else {
            print("Plan ID is null.")
            return
        }
        guard let checkedPosition = position else {
            print("Position is null.")
            return
        }
        trainingPlans[checkedPosition].name = planNameText
        plansDatabaseHelper.updatePlanName(planId: checkedPlanId, newName: planNameText)
    }
    
    func deletePlan(planName: String?, position: Int?) throws {
        guard let planName = planName else {
            throw ValidationException(message: "Plan's name was found null when deleting plan")
        }
        let userDefaultsSavedPlanName = UserDefaultsUtils.shared.getSelectedPlan()
        if planName == userDefaultsSavedPlanName {
            UserDefaultsUtils.shared.removeSelectedPlan()
        }
        guard let position = position else {
            throw ValidationException(message: "Plan's position was found null when deleting plan")
        }
        
        plansDatabaseHelper.deletePlan(planName: planName)
        trainingPlans.remove(at: position)
    }
}
