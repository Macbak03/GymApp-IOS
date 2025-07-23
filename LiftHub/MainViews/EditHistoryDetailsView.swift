//
//  EditHistoryDetailsView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 17/09/2024.
//

import SwiftUI

struct EditHistoryDetailsView: View {
    @ObservedObject var historyElementViewModel: HistoryElementViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var viewModel = EditHistoryDetailsViewModel()
    
    
    var body: some View {
        NavigationStack {
            VStack {
                EditHistoryDetailsListView(viewModel: viewModel)
            }
            .onAppear(){
                viewModel.loadRoutine(historyElementViewModel: historyElementViewModel)
            }
            .toast(isShowing: $viewModel.showToast, message: viewModel.toastMessage)
            .navigationTitle(historyElementViewModel.historyElement.routineName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        historyElementViewModel.showToast = false
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundStyle(Color.red)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.repeatWorkout = true
                    }) {
                        Text("Repeat")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.editHistoryDetails(historyElementViewModel: historyElementViewModel)
                        if viewModel.historySuccessfullyEdited {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Save")
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.repeatWorkout) {
                if viewModel.planName == Constants.NO_PLAN_NAME {
                    NoPlanWorkoutView(
                        viewModel:
                            NoPlanWorkoutViewModel(
                                workoutDraft: viewModel.workoutDraft,
                                planName: viewModel.planName,
                                routineName: viewModel.routineName,
                                date: CustomDate.getCurrentDate(),
                                intensityIndex: viewModel.intensityIndex,
                                weightUnit: viewModel.weightUnit)
                    )
                } else {
                    WorkoutView(viewModel: WorkoutViewModel(planName: viewModel.planName, routineName: viewModel.routineName, date: CustomDate.getCurrentDate()), homeStateViewModel: HomeStateViewModel())
                }
            }
        }
    }
    
}

struct EditHistoryDetailsView_Previews: PreviewProvider {
    @State static var showToast = true
    @State static var toastMessage: String = ""
    @State static var workoutHistoryElement = WorkoutHistoryElement(planName: "Plan", routineName: "Routine", formattedDate: "17.09.2024", rawDate: "17.09.2024 22:22:22")
    static var previews: some View {
        EditHistoryDetailsView(historyElementViewModel: HistoryElementViewModel(historyElement: workoutHistoryElement, position: 0, showToast: showToast, toastMessage: ""))
    }
}


