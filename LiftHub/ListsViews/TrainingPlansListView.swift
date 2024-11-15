//
//  TrainingPlansListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 08/09/2024.
//

import SwiftUI

struct TrainingPlansListView: View {
    @Binding var trainingPlans: [TrainingPlan]
    let plansDatabaseHelper: PlansDataBaseHelper
    var body: some View {
        List {
            ForEach(trainingPlans.indices, id: \.self) {
                index in
                NavigationLink(
                    destination: RoutinesView(planName: trainingPlans[index].name, plansDatabaseHelper: plansDatabaseHelper),
                    label: {
                        TrainingPlansElementView(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper, position: index)
                    }
                )
                
            }
            .onDelete(perform: { indexSet in
                deletePlan(atOffsets: indexSet)
            })
            .padding(.top, 5)
        }
    }
    private func deletePlan(atOffsets indexSet: IndexSet) {
        indexSet.forEach { index in
            let planName = trainingPlans[index].name
            plansDatabaseHelper.deletePlan(planName: planName)

        }
        trainingPlans.remove(atOffsets: indexSet)
    }
}

struct TrainingPlansElementView: View {
    @Binding var trainingPlans: [TrainingPlan]
    let plansDatabaseHelper: PlansDataBaseHelper
    let position: Int
    @Environment(\.colorScheme) var colorScheme
    @State private var showOptionsDialog = false
    @State private var planName: String = ""
    @State private var openRoutines = false
    @State private var showAlertDialog = false
    @State private var showEditPlanDialog = false
    var body: some View {
        
        HStack {
            Text(planName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.TextColorPrimary)
                .onAppear {
                    // Set the initial value of planName
                    if position < trainingPlans.count {
                        planName = trainingPlans[position].name
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
                
                
                Button(action: {
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
            if position < trainingPlans.count {
                planName = trainingPlans[position].name
            }
        }) {
            CreatePlanDialogView(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper, dialogTitle: "Edit plan's name", confirmButtonTitle: "Ok", state: DialogState.edit, planNameText: planName, position: position)
        }
//        .onTapGesture {
//            //showOptionsDialog = true
//        }
        .alert(isPresented: $showAlertDialog) {
            Alert(
                title: Text("Warning"),
                message: Text("Are you sure you want to delete \(planName)?"),
                primaryButton: .destructive(Text("OK")) {
                    deletePlan()
                },
                secondaryButton: .cancel()
            )
        }
        
    }
    
    private func deletePlan() {
        plansDatabaseHelper.deletePlan(planName: planName)
        trainingPlans.remove(at: position)
    }
}

struct TrainingPlansListView_Previews: PreviewProvider {
    @State static var trainingPlans: [TrainingPlan] = [TrainingPlan(name: "plan1"), TrainingPlan(name: "plan2")]
    static var plansDatabaseHelper = PlansDataBaseHelper()
    
    static var previews: some View {
        TrainingPlansListView(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper)
    }
}
