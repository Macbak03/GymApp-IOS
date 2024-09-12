//
//  WorkoutView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//
import SwiftUI

struct HomeView: View {
    @State private var plans: [TrainingPlan] = []
    @State private var selectedPlan = ""
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Backgroundimage(geometry: geometry, imageName: "workout_icon")
                VStack {
                    VStack(alignment: .center) {
                        Text("Current plan:")
                            .font(.system(size: 25, weight: .bold))
                            .multilineTextAlignment(.center)                        
                        // This Spinner is custom, so let's just place a placeholder
                        Picker("Training Plans", selection: $selectedPlan) {
                            ForEach(plans, id: \.self) { plan in
                                Text(plan.name).tag(plan.description)
                                    
                            }
                        }
                        .frame(minWidth: 100, minHeight: 30)
                        .clipped()
                        .pickerStyle(MenuPickerStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                    .padding(.horizontal, 12)
                    
                    VStack(alignment: .center, spacing: 10) {
                        Text("Last workout:")
                            .font(.system(size: 25, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        VStack {
                            Text("Plan name")
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                            
                            HStack {
                                Text("Date")
                                    .font(.system(size: 23, weight: .bold))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.leading, 10)
                                
                                Text("Routine Name")
                                    .font(.system(size: 23))
                                    .frame(maxWidth: .infinity)
                                    .padding(.trailing, 10)
                            }
                            .padding(5)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .shadow(radius: 3)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    // Two buttons (Return to workout and Start Workout)
                    VStack(spacing: 20) {
                        Button(action: {
                            // Action for "Return to workout"
                        }) {
                            Text("Return to workout")
                                .font(.system(size: 18))
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 70)
                        
                        Button(action: {
                            // Action for "Start Workout"
                        }) {
                            Text("Start Workout")
                                .font(.system(size: 18))
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 70)
                        .padding(.bottom, 70)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear() {
                initSpinner()
                if !plans.isEmpty {
                    selectedPlan = plans[0].name
                }
            }
        }
    }
    
    private func initSpinner() {
        let plansDatabaseHelper = PlansDataBaseHelper()
        plans = plansDatabaseHelper.getPlans()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


