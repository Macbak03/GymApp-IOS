//
//  RoutinesViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 21/11/2024.
//

import Foundation

class RoutinesViewModel: ObservableObject {
    var planName: String = ""
    var planId: Int64 = -1
    private let plansDatabaseHelper = PlansDataBaseHelper()
    @Published var routines: [TrainingPlanElement] = []
    private let routinesDatabaseHelper = RoutinesDataBaseHelper()
    
    @Published var showToast = false
    @Published var refreshRoutines = false
    @Published var toastMessage = ""
    
    @Published private var performDelete = false
    
    func loadRoutines() {
        guard let checkedPlanId = plansDatabaseHelper.getPlanId(planName: planName) else {
            print("got null planId in loadRoutines")
            return
        }
        planId = checkedPlanId
        routines = routinesDatabaseHelper.getRoutinesInPlan(planId: checkedPlanId)
    }
    
    func initPlanName(planName: String) {
        self.planName = planName
    }
    
    func deleteRoutineWhenSwiped(atOffsets indexSet: IndexSet) {
        indexSet.forEach { index in
            let routineName = routines[index].name
            routinesDatabaseHelper.deleteRoutine(planID: planId, routineName: routineName)
        }
        routines.remove(atOffsets: indexSet)
    }
    
    func deleteRoutine(routineName: String, position: Int) {
        routinesDatabaseHelper.deleteRoutine(planID: planId, routineName: routineName)
        routines.remove(at: position)
    }
    
}
