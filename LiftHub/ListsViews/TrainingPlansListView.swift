//
//  TrainingPlansListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 08/09/2024.
//

import SwiftUI

struct TrainingPlansListView: View {
    @ObservedObject var viewModel: PlansViewModel
    var body: some View {
        List {
            ForEach(viewModel.trainingPlans.indices, id: \.self) {
                index in
                NavigationLink(
                    destination: RoutinesView(planName: viewModel.trainingPlans[index].name),
                    label: {
                        TrainingPlansElementView(viewModel: viewModel, position: index)
                    }
                )
                
            }
//            .onDelete(perform: { indexSet in
//                viewModel.deletePlan(atOffsets: indexSet)
//            })
            .padding(.top, 5)
        }
    }
//    private func deletePlan(atOffsets indexSet: IndexSet) {
//        indexSet.forEach { index in
//            let planName = trainingPlans[index].name
//            plansDatabaseHelper.deletePlan(planName: planName)
//
//        }
//        trainingPlans.remove(atOffsets: indexSet)
//    }
}

struct TrainingPlansElementView: View {
    @ObservedObject var viewModel: PlansViewModel
    @StateObject var planViewModel =  PlanViewModel()
    let position: Int
    @Environment(\.colorScheme) var colorScheme
    @State private var showOptionsDialog = false
//    @State private var planName: String = ""
    @State private var openRoutines = false
    @State private var showAlertDialog = false
    @State private var showEditPlanDialog = false
    var body: some View {
        
        HStack {
            Text(planViewModel.planName ?? "")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.TextColorPrimary)
                .onAppear {
                    // Set the initial value of planName
                    if position < viewModel.trainingPlans.count {
                        
                    }
                }
                .allowsHitTesting(false)
            
            Spacer()
            Menu {
                Button(action: {
                    showEditPlanDialog = true
                }) {
                    HStack {
                        Text("Edit plan's name")
                            .foregroundColor(Color.accentColor)
                        Image(systemName: "square.and.pencil")
                            .padding()
                            .foregroundColor(Color.accentColor)
                    }
                }
                
                
                Button(role: .destructive, action: {
                    showAlertDialog = true
                }) {
                    HStack {
                        Text("Delete")
                            .foregroundColor(Color.red)
                        Image(systemName: "trash")
                            .padding()
                            .foregroundColor(Color.red)
                    }
                    .foregroundStyle(Color.red)
                }
                
            } label: {
                Button(action: {
                }) {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .frame(width: 15, height: 3)
                        .padding()
                        .rotationEffect(.degrees(90))
                }
                .frame(width: 30, height: 20)
                .background(Color.clear) // You can modify this to fit the background style
            }

        }
            
        .sheet(isPresented: $showEditPlanDialog, onDismiss: {
            if position < viewModel.trainingPlans.count {
                planViewModel.planName = viewModel.trainingPlans[position].name
            }
        }) {
            CreatePlanDialogView(plansViewModel: viewModel, planViewModel: planViewModel, dialogTitle: "Edit plan's name", confirmButtonTitle: "Ok", state: DialogState.edit, planNameText: planViewModel.planName ?? "")
        }
        .alert(isPresented: $showAlertDialog) {
            Alert(
                title: Text("Warning"),
                message: Text("Are you sure you want to delete \(String(describing: planViewModel.planName))?"),
                primaryButton: .destructive(Text("OK")) {
                    do {
                        try viewModel.deletePlan(planName: planViewModel.planName, position: planViewModel.position)
                    } catch let exception as ValidationException {
                        print(exception.message)
                    } catch {
                        print("Unexpected error occured when deleting plan: \(error)")
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear(){
            if position < viewModel.trainingPlans.count {
                planViewModel.initViewModel(planName: viewModel.trainingPlans[position].name, position: position)
            }
        }
        
    }
}

struct TrainingPlansListView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingPlansListView(viewModel: PlansViewModel())
    }
}
