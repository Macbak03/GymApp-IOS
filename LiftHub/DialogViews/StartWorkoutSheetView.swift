//
//  StartWorkoutSheetView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 13/09/2024.
//

import SwiftUI

struct StartWorkoutSheetView: View {
    let planName: String
    @State private var routines: [TrainingPlanElement] = []
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
                    
                    ScrollView {
                        ForEach(routines.indices, id: \.self) {
                            index in
                            SheetListElement(routine: routines[index], planName: planName)
                        }
                        .padding(.top, 5)
                    }
                    .frame(maxHeight: 350)
                    
                }
                .background(Color.BackgroundColor)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)
                .frame(maxWidth: .infinity) // Take the full width at the bottom
            }
        }
        .onAppear(){
            initRoutines()
        }
    }
    
    private func initRoutines(){
        let plansDatabaseHelper = PlansDataBaseHelper()
        guard let planId = plansDatabaseHelper.getPlanId(planName: planName) else {
            print("Plan name in StartWorkoutSheet was null")
            return
        }
        let routinesDatabaseHelper = RoutinesDataBaseHelper()
        routines = routinesDatabaseHelper.getRoutinesInPlan(planId: planId)
    }
}

private struct SheetListElement: View {
    @State private var startWorkout = false
    let routine: TrainingPlanElement
    let planName: String
    var body: some View {
        HStack {
            Text(routine.name)
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(Color.TextColorPrimary)
                .padding(.leading, 5)
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.BackgroundColorList)
                .shadow(radius: 3)
        )
        .padding(.horizontal, 8) // Card marginHorizontal
        
        .onTapGesture {
            startWorkout = true
        }
        .fullScreenCover(isPresented: $startWorkout) {
            WorkoutView(planName: planName, routineName: routine.name)
        }
    }
}


struct StartWorkoutSheet_Previews: PreviewProvider {
    static var planName = "Plan"
    static var previews: some View {
        StartWorkoutSheetView(planName: planName)
        SheetListElement(routine: TrainingPlanElement(name: "Rotuine"), planName: planName)
    }
}

