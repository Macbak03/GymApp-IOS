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
        ScrollView {
            ForEach(trainingPlans.indices, id: \.self) {
                index in
                TrainingPlansElementView(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper, position: index)
            }
            .padding(.top, 5)
        }
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
    var body: some View {
        
        HStack {
            Text(planName)
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(Color.TextColorPrimary)
                .padding(.leading, 5)
                .onAppear {
                    // Set the initial value of planName
                    if position < trainingPlans.count {
                        planName = trainingPlans[position].name
                    }
                }
            
            Spacer()
            
            Button(action: {
                showOptionsDialog = true
            }) {
                Image(systemName: "ellipsis")
                    .resizable()
                    .frame(width: 20, height: 5)
                    .padding()
                    .rotationEffect(.degrees(90))
            }
            .frame(width: 30, height: 50)
            .background(Color.clear) // You can modify this to fit the background style
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.BackgroundColorList)
                .shadow(radius: 3)
        )
        .padding(.horizontal, 8) // Card marginHorizontal
        .sheet(isPresented: $showOptionsDialog, onDismiss: {
            if position < trainingPlans.count {
                planName = trainingPlans[position].name
            }
        }) {
            PlanOptionsDialog(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper, position: position)
        }
        .onTapGesture {
            openRoutines = true
        }
        .fullScreenCover(isPresented: $openRoutines) {
            RoutinesView(planName: planName, plansDatabaseHelper: plansDatabaseHelper)
        }
    }
}

struct TrainingPlansListView_Previews: PreviewProvider {
    @State static var trainingPlans: [TrainingPlan] = [TrainingPlan(name: "plan1"), TrainingPlan(name: "plan2")]
    static var plansDatabaseHelper = PlansDataBaseHelper()
    
    static var previews: some View {
        TrainingPlansListView(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper)
    }
}
