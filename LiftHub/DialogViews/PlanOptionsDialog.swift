//
//  OptionsDialog.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 08/09/2024.
//



// TODO: Nazwa planu nie zmiania sie dynamicznie z edycją tylko po ponownym zaladowaniu widoku
import SwiftUI

struct PlanOptionsDialog: View {
    @Binding var trainingPlans: [TrainingPlan]
    let plansDatabaseHelper: PlansDataBaseHelper
    @Binding var planName: String
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var showEditPlanDialog = false
    var body: some View {
        ZStack{
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all) // Makes sure the background covers the entire screen
                .blur(radius: 50)
            VStack {
                Spacer()
                VStack{
                    // Image (SwipeButton equivalent)
                    Image(systemName: "rectangle.fill") // Substitute with your custom image
                        .resizable()
                        .frame(width: 60, height: 7)
                        .padding(.top, 5)
                        .foregroundColor(.gray) // Replace this with an appropriate background color if needed
                        .frame(maxWidth: .infinity)
                    
                    // Text Views inside a VStack
                    VStack(alignment: .center, spacing: 15) {
                        Text(planName)
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(Color.textColorPrimary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 15)
                    .padding(.horizontal, 10)
                    
                    // Edit Button
                    Button(action: {
                        showEditPlanDialog = true
                    }) {
                        Text("Edit plan's name")
                            .font(.system(size: 18))
                            .foregroundColor(Color.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.accentColor)
                                    .shadow(radius: 3)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    .sheet(isPresented: $showEditPlanDialog) {
                        CreatePlanDialogView(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper, dialogTitle: "Edit plan's name", confirmButtonTitle: "Ok", state: DialogState.edit, planNameText: planName, planName: Binding<String?>(
                            get: { self.planName },   // Getter: Returns the non-optional value
                            set: { self.planName = $0 ?? "" })
                                             )
                    }
                    
                    // Delete Button
                    Button(action: {
                        // Delete action here
                    }) {
                        Text("Delete")
                            .font(.system(size: 18))
                            .foregroundColor(Color.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red)
                                    .shadow(radius: 3)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 5)
                    
                    // Cancel Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 18))
                            .foregroundColor(Color.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.accentColor)
                                    .shadow(radius: 3)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 15)
                    .padding(.bottom, 50)
                    
                }
                .background(Color.BackgroundColor)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)
                .frame(maxWidth: .infinity) // Take the full width at the bottom
            }
        }
    }
}

struct OptionsDialog_Previews: PreviewProvider {
    @State static var trainingPlans: [TrainingPlan] = [TrainingPlan(name: "plan1"), TrainingPlan(name: "plan2")]
    static var plansDatabaseHelper = PlansDataBaseHelper()
    @State static var planName = "Plan"
    static var previews: some View {
        PlanOptionsDialog(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper, planName: $planName)
    }
}
