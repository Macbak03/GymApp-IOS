//
//  RoutinesListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI

struct RoutinesListView: View {
    @Binding var routines: [TrainingPlanElement]
    var body: some View {
        ScrollView {
            ForEach(routines.indices, id: \.self) {
                index in
                RoutinesElementView(routines: $routines, position: index)
            }
        }
    }
}

struct RoutinesElementView: View {
    @Binding var routines: [TrainingPlanElement]
    let position: Int
    @Environment(\.colorScheme) var colorScheme
    @State private var showOptionsDialog = false
    @State var routineName: String = ""
    @State private var openRoutine = false
    var body: some View {
        
        HStack {
            Text(routineName)
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(Color.TextColorPrimary)
                .padding(.leading, 5)
                .onAppear {
                    // Set the initial value of planName
                    if position < routines.count {
                        routineName = routines[position].name
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
        .sheet(isPresented: $showOptionsDialog) {
            //sheet
        }
        .onTapGesture {
            openRoutine = true
        }
        .fullScreenCover(isPresented: $openRoutine) {
            //open routine
        }
    }
}

struct RoutinesListView_Previews: PreviewProvider {
    @State static var routines: [TrainingPlanElement] = [TrainingPlanElement(name: "routine"), TrainingPlanElement(name: "routine1")]
    static var previews: some View {
        RoutinesListView(routines: $routines)
    }
}

