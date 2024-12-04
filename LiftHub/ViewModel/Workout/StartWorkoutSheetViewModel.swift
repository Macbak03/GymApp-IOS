//
//  StartWorkoutSheetViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 28/11/2024.
//

import Foundation

class StartWorkoutSheetViewModel: ObservableObject {
    @Published var trainingPlans = [TrainingPlan]()
    @Published var routines = [TrainingPlanElement]()
    
    @Published var selectedPlan = ""
    
    @Published var isNoPlanOptionSelected = false
    @Published var isListVisible = false
    
    private let plansDatabaseHelper = PlansDataBaseHelper()
    
    @Published var intensityIndex = IntensityIndex(rawValue: UserDefaultsUtils.shared.getIntensity())!
    @Published var weightUnit = WeightUnit(rawValue: UserDefaultsUtils.shared.getWeightUnit())!
    
    func initPickerChoice() {
        selectedPlan = UserDefaultsUtils.shared.getSelectedPlan()
    }
    func initPickerData() {
        trainingPlans = plansDatabaseHelper.getPlans()
        trainingPlans.insert(TrainingPlan(name: Constants.NO_PLAN_NAME), at: 0)
    }
    
    func initRoutines(){
        guard let planId = plansDatabaseHelper.getPlanId(planName: selectedPlan) else {
            print("Plan name in StartWorkoutSheet was null")
            return
        }
        let routinesDatabaseHelper = RoutinesDataBaseHelper()
        routines = routinesDatabaseHelper.getRoutinesInPlan(planId: planId)
    }
    
    func checkIfNoTrainingPlanSelected() {
        if selectedPlan == Constants.NO_PLAN_NAME {
            isNoPlanOptionSelected = true
        } else {
            isNoPlanOptionSelected = false
        }
    }
    
}
