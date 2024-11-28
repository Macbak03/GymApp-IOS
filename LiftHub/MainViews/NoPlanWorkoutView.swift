//
//  NoPlanWorkoutView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 19/09/2024.
//

import SwiftUI

struct NoPlanWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var viewModel: NoPlanWorkoutViewModel
    @StateObject var stateViewModel = WorkoutStateViewModel()
    
    @ObservedObject var homeStateViewModel: HomeStateViewModel
    
    @FocusState private var isWorkoutNameFocused: Bool
    
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    HStack {
                        Spacer() // Push the TextField to the center

                        ZStack {
                            TextField("Enter workout name", text: $viewModel.routineName)
                                .font(.system(size: 18))
                                .frame(height: 40)
                                .background(Color.ShadowColor)
                                .cornerRadius(10)
                                .padding(.horizontal, 35)
                                .multilineTextAlignment(.center)
                                .focused($isWorkoutNameFocused)
                                .onChange(of: isWorkoutNameFocused) { _, focused in
                                    viewModel.validateWorkoutName(focused: focused, workoutStateViewModel: stateViewModel)
                                }
                            
                            
                            
                            if viewModel.showNameError {
                                HStack {
                                    Spacer()
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .resizable()
                                        .foregroundColor(.red)
                                        .frame(width: 25, height: 25)
                                }
                            }
                        }
                        Spacer() // Push the TextField to the center
                    }
                }
                .padding(.bottom, 10)
                
                NoPlanWorkoutListView(viewModel: viewModel, stateViewModel: stateViewModel)
                
            }
            .onAppear(){
                viewModel.loadRoutine(isWorkoutSaved: stateViewModel.isWorkoutSaved, isWorkoutEnded: homeStateViewModel.isWorkoutEnded)
            }
            .onDisappear(){
                if !stateViewModel.isWorkoutFinished {
                    homeStateViewModel.isWorkoutEnded = false
                    viewModel.saveWorkoutToFile()
                }
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
                        UserDefaults.standard.setValue(true, forKey: Constants.IS_WORKOUT_SAVED_KEY)
                        homeStateViewModel.isWorkoutEnded = true
                        stateViewModel.isWorkoutFinished = true
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
            .toast(isShowing: $stateViewModel.showToast, message: stateViewModel.toastMessage)
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
                            viewModel.saveWorkoutToHistory(workoutStateViewModel: stateViewModel, homeStateViewModel: homeStateViewModel)
                        }) {
                            Text("Save")
                        }
                        Button(action: {
                            viewModel.addExercise()
                        }) {
                            Image(systemName: "plus.circle")
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

struct NoPlanWorkoutView_Previews: PreviewProvider {
    @State static var closeWorkutSheet = true
    @State static var isWorkoutEnded = true
    @State static var unfinishedRoutineName: String? = nil
    @State static var showToast = true
    @State static var toastMessage: String = ""
    @State static var rotineName = "Routine"
    static var previews: some View {
        NoPlanWorkoutView(viewModel: NoPlanWorkoutViewModel(planName: "", date: "", intensityIndex: IntensityIndex.RPE, weightUnit: WeightUnit.kg), homeStateViewModel: HomeStateViewModel())
    }
}


