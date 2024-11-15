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
    
    private let routinesDatabaseHelper = RoutinesDataBaseHelper()
    @State private var showAlertDialog = false
    @State private var indexSet: IndexSet = []
    
    var body: some View {
        List {
            ForEach(routines.indices, id: \.self) { index in
            NavigationLink(
                destination: RoutineView(originalRoutineName: routines[index].name, planName: planName, planId: planId, refreshRoutines: $refreshRoutines, successfullySaved: $showToast, savedMessage: $toastMessage),
                label: {
                    RoutinesElementView(routines: $routines, position: index, routine: $routines[index], planName: planName, planId: planId, showToast: $showToast, refreshRoutines: $refreshRoutines, toastMessage: $toastMessage, performDelete: $performDelete)
                }
                )
            }
            .onDelete(perform: { indexSet in
                self.indexSet = indexSet
                showAlertDialog = true
            })
            .padding(.top, 5)
        }
        .alert(isPresented: $showAlertDialog) {
            var routineName = ""
            indexSet.forEach { index in
                routineName = routines[index].name
            }
            return Alert(
                title: Text("Warning"),
                message: Text("Are you sure you want to delete \(routineName)?"),
                primaryButton: .destructive(Text("OK")) {
                    deleteRoutine(atOffsets: indexSet)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    
    private func deleteRoutine(atOffsets indexSet: IndexSet) {
        indexSet.forEach { index in
            let routineName = routines[index].name
            routinesDatabaseHelper.deleteRoutine(planID: planId, routineName: routineName)
        }
        routines.remove(atOffsets: indexSet)
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
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.TextColorPrimary)
                    //.padding(.leading, 5)
                    .onChange(of: refreshRoutines) { _, refreshNeeded in
                        if refreshNeeded {
                            routineName = routine.name
                        }
                    }
                    .onAppear() {
                        routineName = routine.name
                    }
                    .allowsHitTesting(false)

                
                Spacer()
                
                Button(action: {
                    showOptionsDialog = true
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
            .alert(isPresented: $showOptionsDialog) {
                Alert(
                    title: Text("Warning"),
                    message: Text("Are you sure you want to delete \(routineName)?"),
                    primaryButton: .destructive(Text("OK")) {
                        deleteRoutine()
                    },
                    secondaryButton: .cancel()
                )
            }
            .onTapGesture {
                showOptionsDialog = true
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

