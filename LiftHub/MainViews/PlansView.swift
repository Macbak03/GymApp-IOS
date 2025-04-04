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
            VStack {
                if viewModel.trainingPlans.isEmpty {
                    Button(action : {
                        showCreatePlanDialog = true
                    }) {
                        VStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 70, height: 70)
                            Text("Create Training Plan")
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    
                    
                } else {
                    TrainingPlansListView(viewModel: viewModel)
                }
                    
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
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
        .onAppear() {
            viewModel.loadPlans()
        }
    }
    
}

struct PlansView_Previews: PreviewProvider {
    static var previews: some View {
        PlansView()
    }
}
