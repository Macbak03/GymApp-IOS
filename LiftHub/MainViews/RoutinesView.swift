//
//  Routines.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI
import Foundation

struct RoutinesView: View {
    @State private var routines: [TrainingPlanElement] = []
    @State private var openRoutine = false
    let planName: String
    let plansDatabaseHelper: PlansDataBaseHelper
    private let routinesDatabaseHelper = RoutinesDataBaseHelper()
    @Environment(\.presentationMode) var presentationMode // Allows us to dismiss this view
    
    @State private var showToast = false
    @State private var refreshRoutines = false
    @State private var toastMessage = ""
    
    @State private var performDelete = false
    
    @State private var planId: Int64 = -1
    
    var body: some View {
        
        
        GeometryReader { geometry in
            ZStack {
                VStack {
                    
                    RoutinesListView(routines: $routines, planName: planName, planId: planId, showToast: $showToast, refreshRoutines: $refreshRoutines, toastMessage: $toastMessage, performDelete: $performDelete)
                        .onChange(of: refreshRoutines) { refreshNeeded in
                            if refreshNeeded {
                                loadRoutines()
                                refreshRoutines = false
                            }
                            
                        }
                        .onAppear() {
                            loadRoutines()
                        }
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .fullScreenCover(isPresented: $openRoutine) {
                    RoutineView(originalRoutineName: nil, planName: planName, planId: planId, refreshRoutines: $refreshRoutines, successfullySaved: $showToast, savedMessage: $toastMessage)
                }
            }
            .navigationTitle(planName)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(
                        destination: RoutineView(originalRoutineName: nil, planName: planName, planId: planId, refreshRoutines: $refreshRoutines, successfullySaved: $showToast, savedMessage: $toastMessage),
                        label: {
                            Image(systemName: "plus")
                        }
                    )
                }
            }
            .toast(isShowing: $showToast, message: toastMessage)
            .onAppear() {
                guard let checkedPlanId = plansDatabaseHelper.getPlanId(planName: planName) else {
                    return
                }
                planId = checkedPlanId
            }
        }
    }
    
    private func loadRoutines() {
        routines = routinesDatabaseHelper.getRoutinesInPlan(planId: planId)
    }
}


private struct AddButton: View {
    @Binding var openRoutine: Bool
    let geometry: GeometryProxy
    var buttonScale = 0.14
    var buttonOffsetX = 0.35
    var buttonOffsetY = 0.1
    let planName: String
    var body: some View {
        Button(action: {
            openRoutine = true
        }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: geometry.size.width * buttonScale, height: geometry.size.width * buttonScale)
        }
        .position(x: geometry.size.width * buttonOffsetX, y: geometry.size.height * buttonOffsetY)
        .frame(
            width: geometry.size.width * buttonScale,
            height: geometry.size.height * buttonScale
        )
    }
}

struct RoutinesView_Previews: PreviewProvider {
    static var plansDatabaseHelper = PlansDataBaseHelper()
    static var previews: some View {
        RoutinesView(planName: "Plan", plansDatabaseHelper: plansDatabaseHelper)
    }
}
