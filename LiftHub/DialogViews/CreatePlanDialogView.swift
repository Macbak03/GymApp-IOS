//
//  CreatePlanDialogView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 08/09/2024.
//

import SwiftUI

struct CreatePlanDialogView: View {
    @ObservedObject var plansViewModel: PlansViewModel
    @ObservedObject var planViewModel: PlanViewModel
    let dialogTitle: String
    let confirmButtonTitle: String
    let state: DialogState
    @State var planNameText: String
    //let position: Int?
    //@State var planName: String = ""
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
                        .font(.system(size: 18))
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
                                    try plansViewModel.addPlan(planName: planNameText)
                                    presentationMode.wrappedValue.dismiss()
                                } catch let error as ValidationException {
                                    toastMessage = error.message
                                    showToast = true
                                } catch {
                                    toastMessage = "An unexpected error occured \(error)"
                                    showToast = true
                                }
                            } else {
                                do {
                                    try plansViewModel.editPlan(planName: planViewModel.planName, planNameText: planNameText, position: planViewModel.position)
                                    presentationMode.wrappedValue.dismiss()
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
            }
            .toast(isShowing: $showToast, message: toastMessage)
        }
    }
}

struct CreatePlanDialogView_Previews: PreviewProvider {
    @State static var trainingPlans: [TrainingPlan] = [TrainingPlan(name: "plan1"), TrainingPlan(name: "plan2")]
    @State static var planName: String?
    static var previews: some View {
        CreatePlanDialogView(plansViewModel: PlansViewModel(), planViewModel: PlanViewModel(), dialogTitle: "Create training plan", confirmButtonTitle: "Add plan", state: DialogState.add, planNameText: "")
    }
}
