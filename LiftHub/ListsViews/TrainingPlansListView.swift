//
//  TrainingPlansListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 08/09/2024.
//

import SwiftUI

struct TrainingPlansListView: View {
    @Binding var trainingPlans: [TrainingPlan]
    let geometry: GeometryProxy
    var body: some View {
        ScrollView {
            ForEach(trainingPlans) {
                plan in 
                TrainingPlansElementView(plan: plan)
            }
        }
    }
}

struct TrainingPlansElementView: View {
    let plan: TrainingPlan
    @Environment(\.colorScheme) var colorScheme
    //var onMoreButtonTap: () -> Void
    var body: some View {
        HStack {
            Text(plan.name)
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(Color.TextColorPrimary)
                .padding(.leading, 5)
            
            Spacer()
            
            Button(action: {
                //onMoreButtonTap()
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
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.BackgroundColorList)
                .shadow(radius: 3)
        )
        .padding(.horizontal, 8) // Card marginHorizontal
    }
}

struct TrainingPlansElementView_Previews: PreviewProvider {
    @State static var trainingPlans: [TrainingPlan] = [TrainingPlan(name: "plan1"), TrainingPlan(name: "plan2")]
    static var previews: some View {
        GeometryReader { geometry in
            TrainingPlansListView(trainingPlans: $trainingPlans, geometry: geometry)
        }
    }
}
