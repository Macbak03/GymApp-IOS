//
//  StartWorkoutSheetView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 13/09/2024.
//

import SwiftUI

struct StartWorkoutSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = StartWorkoutSheetViewModel()
    @ObservedObject var homeStateViewModel: HomeStateViewModel
    @State private var closeWorkoutSheetView = false
    @State private var animateList = false
    @State private var startNoPlanWorkout = false
    var body: some View {
        NavigationStack {
                VStack {
                    VStack{
                        Menu {
                            Picker(selection: $viewModel.selectedPlan) {
                                ForEach(viewModel.trainingPlans, id: \.self) { plan in
                                    Text(plan.name).tag(plan.description)
                                }
                            } label: {}
                                .frame(minWidth: 100, minHeight: 30)
                                .clipped()
                                .onChange(of: viewModel.selectedPlan) { _, plan in
                                    UserDefaultsUtils.shared.setSelectedPlan(planName: plan)
                                }
                                .disabled(!UserDefaultsUtils.shared.getHasWorkoutEnded())
                        } label: {
                            HStack {
                                Text(viewModel.selectedPlan)
                                    .font(.system(size: 18))
                                Image(systemName: "chevron.up.chevron.down")
                            }
                        }
                        .padding(.vertical, 10)
                        
                        if viewModel.routines.isEmpty && !viewModel.isNoPlanOptionSelected {
                            NavigationLink(destination: {
                                RoutinesView(planName: viewModel.selectedPlan)
                            }, label: {
                                VStack {
                                    Text("To start workout, create a routine first.")
                                    Text("Create routine")
                                        .foregroundColor(Color.TextColorTetiary)
                                        .font(.system(size: 18))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.ColorSecondary)
                                        .cornerRadius(20)
                                        .shadow(radius: 2)
                                }
                                .padding(.horizontal, 70)
                                .padding(.bottom, 20)
                            })
                            
                        }
                        
                        if viewModel.isNoPlanOptionSelected {
                            Button(action: {
                                startNoPlanWorkout = true
                            }) {
                                Text("Start no plan workout")
                                    .foregroundColor(Color.TextColorTetiary)
                                    .font(.system(size: 18))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.ColorSecondary)
                                    .cornerRadius(20)
                                    .shadow(radius: 2)
                            }
                            .padding(.horizontal, 70)
                            .padding(.bottom, 20)
                        } else {
                            List {
                                ForEach(viewModel.routines.indices, id: \.self) {
                                    index in
                                    SheetListElement(homeStateViewModel: homeStateViewModel, routine: viewModel.routines[index], planName: viewModel.selectedPlan, closeWorkoutSheetElement: $closeWorkoutSheetView)
                                        .id(viewModel.selectedPlan)
                                        .transition(.move(edge: .bottom))
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: animateList)
                        }
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: viewModel.isListVisible ? 150:350)
                    .clipped()
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isListVisible)
                }
            }
            .onAppear(){
                viewModel.initPickerData()
                viewModel.initPickerChoice()
                viewModel.checkIfNoTrainingPlanSelected()
                if !viewModel.isNoPlanOptionSelected {
                    viewModel.initRoutines()
                }
            }
            .onChange(of: closeWorkoutSheetView) { _, close in
                if close {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .onChange(of: viewModel.selectedPlan) { _, _ in
                viewModel.checkIfNoTrainingPlanSelected()
                if !viewModel.isNoPlanOptionSelected {
                    viewModel.initRoutines()
                    animateList = false
                    withAnimation {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            animateList = true
                        }
                    }
                } else { 
                    withAnimation {
                        animateList = false
                    }
                }
            }
            .onChange(of: viewModel.isNoPlanOptionSelected) { _, _ in
                withAnimation {
                    viewModel.isListVisible = viewModel.isNoPlanOptionSelected
                }
            }
            .fullScreenCover(isPresented: $startNoPlanWorkout, onDismiss: { closeWorkoutSheetView = true
            }) {
                NoPlanWorkoutView(
                    viewModel:
                        NoPlanWorkoutViewModel(
                            planName: Constants.NO_PLAN_NAME,
                            date: CustomDate.getCurrentDate(),
                            intensityIndex: viewModel.intensityIndex,
                            weightUnit: viewModel.weightUnit))
            }
        }
}

private struct SheetListElement: View {
    @State private var startWorkout: Bool = false
    @ObservedObject var homeStateViewModel: HomeStateViewModel
    let routine: TrainingPlanElement
    let planName: String
    @Binding var closeWorkoutSheetElement: Bool
    @State private var date: String = CustomDate.getCurrentDate()
    var body: some View {
        HStack {
            HStack {
                Text(routine.name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.TextColorPrimary)
                    .padding(.leading, 5)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .padding(.trailing, 5)
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 15))
            }
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, minHeight: 35)
        .onTapGesture {
            UserDefaults.standard.setValue(true, forKey: Constants.IS_WORKOUT_SAVED_KEY)
            startWorkout = true
        }
        .fullScreenCover(isPresented: $startWorkout, onDismiss: {
            closeWorkoutSheetElement = true
        }) {
            WorkoutView(
                viewModel:
                    WorkoutViewModel(
                        planName: planName,
                        routineName: routine.name,
                        date: date),
                homeStateViewModel: homeStateViewModel
            )
        }
    }
}


struct StartWorkoutSheet_Previews: PreviewProvider {
    @State static var isWorkoutEnded = false
    @State static var startWorkout = false
    @State static var unfinishedRoutineName: String = ""
    static var planName = "Plan"
    static var previews: some View {
        StartWorkoutSheetView(homeStateViewModel: HomeStateViewModel())
    }
}

