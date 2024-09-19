//
//  CreatePlanDialogView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 08/09/2024.
//

import SwiftUI

struct CreatePlanDialogView: View {
    @Binding var trainingPlans: [TrainingPlan]
    let plansDatabaseHelper: PlansDataBaseHelper
    let dialogTitle: String
    let confirmButtonTitle: String
    let state: DialogState
    @State var planNameText: String
    let position: Int?
    @State var planName: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var showToast = false
    @State private var toastMessage = ""
    
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all) // Makes sure the background covers the entire screen
                .blur(radius: 50)
            VStack {
                Spacer() // Pushes the content down to the bottom
                
                VStack {
                    // Title at the top, centered horizontally
                    Text(dialogTitle)
                        .font(.title)
                        .padding(.top)
                    
                    // TextField for entering plan name
                    TextField("Enter training plan name", text: $planNameText)
                        .padding()
                        .background(Color.ShadowColor)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    // HStack to arrange Cancel and Add Plan buttons
                    HStack {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                        .padding()
                        
                        Spacer() // Pushes the buttons to the sides
                        
                        Button(action: {
                            if state == DialogState.add {
                                do {
                                    try addPlan()
                                } catch let error as ValidationException {
                                    toastMessage = error.message
                                    showToast = true
                                } catch {
                                    toastMessage = "An unexpected error occured \(error)"
                                    showToast = true
                                }
                            } else {
                                do {
                                    try editPlan()
                                } catch let error as ValidationException {
                                    toastMessage = error.message
                                    showToast = true
                                } catch {
                                    toastMessage = "An unexpected error occured \(error)"
                                    showToast = true
                                }
                            }
                        }) {
                            Text(confirmButtonTitle)

                        }
                        .disabled(planNameText.isEmpty)
                        .padding()
                    }
                    .padding(.horizontal)
                    
                }
                .background(Color.BackgroundColor)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)
                .frame(maxWidth: .infinity) // Take the full width at the bottom
                .onAppear() {
                    if let position = position, position < trainingPlans.count {
                        planName = trainingPlans[position].name
                    }
                }
            }
            .toast(isShowing: $showToast, message: toastMessage)
        }
    }
    
    func addPlan() throws {
        if planNameText.isEmpty {
            throw ValidationException(message: "Plan's name cannot be empty")
        }
        
        if trainingPlans.contains(where: { $0.name == planNameText }) {
            throw ValidationException(message: "A plan with this name already exists")
        }
        
        plansDatabaseHelper.addPlan(planName: planNameText)
        trainingPlans.append(TrainingPlan(name: planNameText))
        presentationMode.wrappedValue.dismiss()
    }
    
    func editPlan() throws {
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
        plansDatabaseHelper.updatePlanName(planId: checkedPlanId, newName: planNameText)
        trainingPlans[checkedPosition].name = planNameText
        presentationMode.wrappedValue.dismiss()
    }
}

struct CreatePlanDialogView_Previews: PreviewProvider {
    @State static var trainingPlans: [TrainingPlan] = [TrainingPlan(name: "plan1"), TrainingPlan(name: "plan2")]
    static var plansDatabaseHelper = PlansDataBaseHelper()
    @State static var planName: String?
    static var previews: some View {
        CreatePlanDialogView(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper,dialogTitle: "Create training plan", confirmButtonTitle: "Add plan", state: DialogState.add, planNameText: "", position: nil)
    }
}
