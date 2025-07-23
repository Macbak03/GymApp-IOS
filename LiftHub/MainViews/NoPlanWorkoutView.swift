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
                                .frame(height: 35)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke((viewModel.showNameError ? Color.red : Color.textFieldOutline), lineWidth: 1)
                                )
                                .padding(.horizontal, 45)
                                .multilineTextAlignment(.center)
                                .focused($isWorkoutNameFocused)
                                .onChange(of: isWorkoutNameFocused) { _, focused in
                                    viewModel.validateWorkoutName(focused: focused, workoutStateViewModel: stateViewModel)
                                }
                            
                        }
                        Spacer() // Push the TextField to the center
                    }
                }
                .padding(.bottom, 10)
                
                NoPlanWorkoutListView(viewModel: viewModel, stateViewModel: stateViewModel)
                
            }
            .onAppear(){
                viewModel.loadRoutine(isWorkoutSaved: stateViewModel.isWorkoutSaved)
            }
            .onDisappear(){
                if !stateViewModel.isWorkoutFinished {
                    UserDefaultsUtils.shared.setHasWorkoutEnded(false)
                    //homeStateViewModel.isWorkoutEnded = false
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
                        viewModel.clearWorkoutData(workoutStateViewModel: stateViewModel)
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
                            viewModel.saveWorkoutToHistory(workoutStateViewModel: stateViewModel)
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
//                ToolbarItem(placement: .bottomBar) {
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            viewModel.addExercise()
//                        }) {
//                            Image(systemName: "plus")
//                                .resizable()
//                                .frame(width: 22, height: 22)
//                                .padding(.trailing, 5)
//                                .foregroundStyle(Color.accentColor)
//                        }
//                        .frame(width: 30, height: 30)
//                        .padding(.trailing)
//                    }
//                }
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
        NoPlanWorkoutView(viewModel: NoPlanWorkoutViewModel(planName: "", date: "", intensityIndex: IntensityIndex.RPE, weightUnit: WeightUnit.kg))
    }
}


