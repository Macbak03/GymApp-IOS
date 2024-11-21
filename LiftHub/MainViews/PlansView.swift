//
//  PlansView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//

import SwiftUI
import Foundation

struct PlansView: View {
    @StateObject var viewModel = PlansViewModel()
    @State private var showCreatePlanDialog = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Backgroundimage(geometry: geometry, imageName: "plans_icon")
                VStack {
                    TrainingPlansListView(viewModel: viewModel)
                        .onAppear() {
                            viewModel.loadPlans()
                        }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action : {
                    showCreatePlanDialog = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreatePlanDialog) {
            CreatePlanDialogView(plansViewModel: viewModel, planViewModel: PlanViewModel(), dialogTitle: "Create training plan", confirmButtonTitle: "Add plan", state: DialogState.add, planNameText: "")
        }
    }
    
//    func loadPlans() {
//        trainingPlans = plansDatabaseHelper.getPlans()
//    }
}

struct PlansView_Previews: PreviewProvider {
    static var previews: some View {
        PlansView()
    }
}
