//
//  RoutinesListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI

struct RoutinesListView: View {
    @Binding var routines: [TrainingPlanElement]
    let planName: String
    let planId: Int64
    
    @Binding var showToast: Bool
    @Binding var refreshRoutines: Bool
    @Binding var toastMessage: String
    
    @Binding var performDelete: Bool
    
    var body: some View {
        ScrollView {
            ForEach(routines.indices, id: \.self) { index in
                RoutinesElementView(routines: $routines, position: index, routine: $routines[index], planName: planName, planId: planId, showToast: $showToast, refreshRoutines: $refreshRoutines, toastMessage: $toastMessage, performDelete: $performDelete)
            }
            .padding(.top, 5)
        }
    }
}

struct RoutinesElementView: View {
    @Binding var routines: [TrainingPlanElement]
    let position: Int
    @Binding var routine: TrainingPlanElement
    let planName: String
    let planId: Int64
    @Environment(\.colorScheme) var colorScheme
    @State private var showOptionsDialog = false
    @State var routineName: String = ""
    @State private var openRoutine = false
    
    @Binding var showToast: Bool
    @Binding var refreshRoutines: Bool
    @Binding var toastMessage: String
    
    @Binding var performDelete: Bool
    
    private let routinesDatabaseHelper = RoutinesDataBaseHelper()
    
    var body: some View {
        ZStack (alignment: .leading) {
            HStack {
                Text(routineName)
                    .font(.system(size: 25, weight: .medium))
                    .foregroundColor(Color.TextColorPrimary)
                    .padding(.leading, 5)
                    .onChange(of: refreshRoutines) { refreshNeeded in
                        if refreshNeeded {
                            routineName = routine.name
                        }
                    }
                    .onAppear() {
                        routineName = routine.name
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
            .actionSheet(isPresented: $showOptionsDialog) {
                ActionSheet(
                    title: Text("Warning"),
                    message: Text("Are you sure you want to delete \(routineName)?"),
                    buttons: [
                        .destructive(Text("Delete"), action: {
                            performDelete = true
                            deleteRoutine()
                        }),
                        .cancel()
                    ]
                )
            }
            .onTapGesture {
                openRoutine = true
            }
            .fullScreenCover(isPresented: $openRoutine) {
                RoutineView(originalRoutineName: routineName, planName: planName, planId: planId, refreshRoutines: $refreshRoutines, successfullySaved: $showToast, savedMessage: $toastMessage)
            }
        }
    }
    
    private func deleteRoutine() {
        routinesDatabaseHelper.deleteRoutine(planID: planId, routineName: routineName)
        routines.remove(at: position)
    }
}

struct RoutinesListView_Previews: PreviewProvider {
    @State static var routines: [TrainingPlanElement] = [TrainingPlanElement(name: "routine"), TrainingPlanElement(name: "routine1")]
    @State static var showToast = false
    @State static var toastMessage = ""
    @State static var refreshRoutines = false
    @State static var performDelete = false
    static var previews: some View {
        RoutinesListView(routines: $routines, planName: "Plan", planId: 0, showToast: $showToast, refreshRoutines: $refreshRoutines, toastMessage: $toastMessage, performDelete: $performDelete)
    }
}

