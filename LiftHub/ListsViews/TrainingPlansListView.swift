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
//                TrainingPlansElementView(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper, position: index)
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
        .sheet(isPresented: $showOptionsDialog, onDismiss: {
            if position < trainingPlans.count {
                planName = trainingPlans[position].name
            }
        }) {
            PlanOptionsDialog(trainingPlans: $trainingPlans, plansDatabaseHelper: plansDatabaseHelper, position: position)
        }
        .onTapGesture {
            showOptionsDialog = true
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
