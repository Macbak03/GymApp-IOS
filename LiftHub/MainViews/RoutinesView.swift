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
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 20, weight: .bold))
                                }
                                Spacer()
                            }
                            .padding(.leading, 40) // Add some padding to keep it away from the edge
                                                        
                            Text(planName)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(Color.TextColorPrimary)
                        }
                    }
                    
                    RoutinesListView(routines: $routines, geometry: geometry)
                    
                    Spacer()
                    
                    AddButton(geometry: geometry)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}


private struct AddButton: View {
    let geometry: GeometryProxy
    var buttonScale = 0.16
    var buttonOffsetX = 0.35
    var buttonOffsetY = 0.1
    var body: some View {
        Button(action: {
            
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
