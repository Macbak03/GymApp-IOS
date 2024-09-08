//
//  CreatePlanDialogView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 08/09/2024.
//

import SwiftUI

struct CreatePlanDialogView: View {
    @Binding var trainingPlans: [TrainingPlan]
    @State private var planName = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all) // Makes sure the background covers the entire screen
                .blur(radius: 50)
            VStack {
                Spacer() // Pushes the content down to the bottom
                
                VStack {
                    // Title at the top, centered horizontally
                    Text("Create Training Plan")
                        .font(.title)
                        .padding(.top)
                    
                    // TextField for entering plan name
                    TextField("Enter training plan name", text: $planName)
                        .padding()
                        .background(Color(.systemGray6))
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
                            addPlan()
                        }) {
                            Text("Add Plan")
                        }
                        .disabled(planName.isEmpty)
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
            //.background(Color.blur())
        }
    }
    
    func addPlan() {
        if planName.isEmpty || planName == PlansView.defaultPlan.name {
            return
        }
        
        if trainingPlans.contains(where: { $0.name == planName }) {
            // Show error: plan with this name already exists
            return
        }
        
        if trainingPlans.first?.name == PlansView.defaultPlan.name {
            trainingPlans.removeAll()
        }
        
        trainingPlans.append(TrainingPlan(name: planName))
        presentationMode.wrappedValue.dismiss()
    }
}

struct CreatePlanDialogView_Previews: PreviewProvider {
    @State static var trainingPlans: [TrainingPlan] = [TrainingPlan(name: "plan1"), TrainingPlan(name: "plan2")]
    static var previews: some View {
        CreatePlanDialogView(trainingPlans: $trainingPlans)
    }
}
