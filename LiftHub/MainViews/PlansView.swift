//
//  PlansView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//

import SwiftUI
import Foundation

struct PlansView: View {
    @State private var trainingPlans: [TrainingPlan] = []
    private let plansDatabaseHelper = PlansDataBaseHelper()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Backgroundimage(geometry: geometry, imageName: "plans_icon")
                VStack {
                    // RecyclerView equivalent (could be a ScrollView or List in SwiftUI)
                    TrainingPlansListView(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper)
                        .onAppear() {
                            loadPlans()
                        }
                    
                    Spacer()
                    
                    AddButton(geometry: geometry, trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    func loadPlans() {
        trainingPlans = plansDatabaseHelper.getPlans()
    }
}

private struct AddButton: View {
    let geometry: GeometryProxy
    @Binding var trainingPlans: [TrainingPlan]
    let plansDatabaseHelper: PlansDataBaseHelper
    
    @State private var showCreatePlanDialog = false
    
    var buttonScale = 0.14
    var buttonOffsetX = 0.35
    var buttonOffsetY = 0.02
    var body: some View {
        Button(action: {
            showCreatePlanDialog = true
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
        .sheet(isPresented: $showCreatePlanDialog) {
            @State var name = ""
            CreatePlanDialogView(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper, dialogTitle: "Create training plan", confirmButtonTitle: "Add plan", state: DialogState.add, planNameText: "", position: nil)
        }
    }
}

struct PlansView_Previews: PreviewProvider {
    static var previews: some View {
        PlansView()
    }
}
