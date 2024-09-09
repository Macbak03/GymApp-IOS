//
//  Routines.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI
import Foundation

struct RoutinesView: View {
    @State private var routines: [TrainingPlanElement] = []
    @State private var openRoutine = false
    let planName: String
    @Environment(\.presentationMode) var presentationMode // Allows us to dismiss this view
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    // HStack for Back Button at the top-left corner
                    HStack {
                        ZStack{
                            HStack{
                                Button(action: {
                                    // Dismiss the current view to go back
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 20, weight: .bold))
                                }
                                Spacer()
                            }
                            .padding(.leading, 30) // Add some padding to keep it away from the edge
                                                        
                            Text(planName)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(Color.TextColorPrimary)
                        }
                    }
                    
                    RoutinesListView(routines: $routines)
                    
                    Spacer()
                    
                    AddButton(openRoutine: $openRoutine ,geometry: geometry, planName: planName)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .fullScreenCover(isPresented: $openRoutine) {
                    RoutineView(planName: planName)
                }
            }
        }
    }
}


private struct AddButton: View {
    @Binding var openRoutine: Bool
    let geometry: GeometryProxy
    var buttonScale = 0.14
    var buttonOffsetX = 0.35
    var buttonOffsetY = 0.1
    let planName: String
    var body: some View {
        Button(action: {
            openRoutine = true
        }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: geometry.size.width * buttonScale, height: geometry.size.width * buttonScale)
        }
        .position(x: geometry.size.width * buttonOffsetX, y: geometry.size.height * buttonOffsetY)
        .frame(
            width: geometry.size.width * buttonScale,
            height: geometry.size.height * buttonScale
        )
    }
}

struct RoutinesView_Previews: PreviewProvider {
    static var previews: some View {
        RoutinesView(planName: "Plan")
    }
}
