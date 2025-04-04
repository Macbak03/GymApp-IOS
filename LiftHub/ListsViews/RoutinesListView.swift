//
//  RoutinesListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI

struct RoutinesListView: View {
    @ObservedObject var viewModel: RoutinesViewModel
    @State private var showAlertDialog = false
    @State private var indexSet: IndexSet = []
    
    var body: some View {
        List {
            ForEach(viewModel.routines.indices, id: \.self) { index in
            NavigationLink(
                destination: RoutineView(originalRoutineName: viewModel.routines[index].name, routinesViewModel: viewModel),
                label: {
                    RoutinesElementView(position: index, routinesViewModel: viewModel)
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
                routineName = viewModel.routines[index].name
            }
            return Alert(
                title: Text("Warning"),
                message: Text("Are you sure you want to delete \(routineName)?"),
                primaryButton: .destructive(Text("OK")) {
                    viewModel.deleteRoutineWhenSwiped(atOffsets: indexSet)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    
//    private func deleteRoutine(atOffsets indexSet: IndexSet) {
//        indexSet.forEach { index in
//            let routineName = viewModel.routines[index].name
//            routinesDatabaseHelper.deleteRoutine(planID: planId, routineName: routineName)
//        }
//        routines.remove(atOffsets: indexSet)
//    }
}

struct RoutinesElementView: View {
    let position: Int
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var routinesViewModel: RoutinesViewModel
    @StateObject var routineViewModel = RoutineViewModel()
    @State private var showOptionsDialog = false
    
    var body: some View {
        ZStack (alignment: .leading) {
            HStack {
                Text(routineViewModel.routine.name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.TextColorPrimary)
                    //.padding(.leading, 5)
                    .onChange(of: routinesViewModel.refreshRoutines) { _, refreshNeeded in
                        if refreshNeeded {
                            //routineName = routineViewModel.routine.name
                        }
                    }
                    .onAppear() {
                        //routineName = routineViewModel.routine.name
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
                    message: Text("Are you sure you want to delete \(routineViewModel.routine.name)?"),
                    primaryButton: .destructive(Text("OK")) {
                        routinesViewModel.deleteRoutine(routineName: routineViewModel.routine.name, position: position)
                    },
                    secondaryButton: .cancel()
                )
            }
            .onTapGesture {
                showOptionsDialog = true
            }
        }
        .onAppear() {
            routineViewModel.initRoutine(routine: routinesViewModel.routines[position])
        }
    }
}

struct RoutinesListView_Previews: PreviewProvider {
    @State static var routines: [TrainingPlanElement] = [TrainingPlanElement(name: "routine"), TrainingPlanElement(name: "routine1")]
    @State static var showToast = false
    @State static var toastMessage = ""
    @State static var refreshRoutines = false
    @State static var performDelete = false
    static var previews: some View {
        RoutinesListView(viewModel: RoutinesViewModel())
    }
}

