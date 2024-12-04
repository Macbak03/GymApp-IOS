//
//  WorkoutView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 13/09/2024.
//

import SwiftUI
import UIKit

struct WorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var stateViewModel =  WorkoutStateViewModel()
    @StateObject var viewModel: WorkoutViewModel

    @ObservedObject var homeStateViewModel: HomeStateViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                WorkoutListView(workout: $viewModel.workoutDraft, workoutHints: $viewModel.workoutHints, workoutStateViewModel: stateViewModel)
                
            }
            .onAppear(){
                viewModel.loadRoutine(isWorkoutSaved: stateViewModel.isWorkoutSaved)
            }
            .onDisappear(){
                if !stateViewModel.isWorkoutFinished {
                    homeStateViewModel.isWorkoutEnded = false
                    viewModel.saveWorkoutToFile()
                }
                homeStateViewModel.closeStartWorkoutSheet = true
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .inactive {
                    viewModel.saveWorkoutToFile()
                }
            }
            .alert(isPresented: $stateViewModel.showCancelAlert) {
                Alert(
                    title: Text("Warning"),
                    message: Text("Workout won't be saved. Do you want to cancel?"),
                    primaryButton: .destructive(Text("Yes")) {
                        UserDefaultsUtils.shared.setWorkoutSaved(workoutSaved: true)
                        homeStateViewModel.isWorkoutEnded = true
                        stateViewModel.isWorkoutFinished = true
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
            .toast(isShowing: $stateViewModel.showToast, message: stateViewModel.toastMessage)
            .navigationTitle(viewModel.routineName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: {
                            stateViewModel.showCancelAlert = true
                        }) {
                            Text("Cancel")
                                .foregroundStyle(Color.red)
                        }
                        Button(action: {
                            stateViewModel.isSaveClicked = true
                            if stateViewModel.isSaveClicked {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    viewModel.saveWorkoutToHistory(workoutStateViewModel: stateViewModel, homeStateViewModel: homeStateViewModel)
                                }
                            } else {
                                viewModel.saveWorkoutToHistory(workoutStateViewModel: stateViewModel, homeStateViewModel: homeStateViewModel)
                            }
                        }) {
                            Text("Save")
                        }
                        
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image (systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            .onChange(of: stateViewModel.isWorkoutFinished) { oldValue, newValue in
                if newValue == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    
}

struct WorkoutView_Previews: PreviewProvider {
    @State static var closeWorkutSheet = true
    @State static var isWorkoutEnded = true
    @State static var unfinishedRoutineName: String? = nil
    @State static var showToast = true
    @State static var toastMessage: String = ""
    @State static var rotineName = "Routine"
    static var previews: some View {
        WorkoutView(viewModel: WorkoutViewModel(planName: "", routineName: "", date: ""), homeStateViewModel: HomeStateViewModel())
    }
}

