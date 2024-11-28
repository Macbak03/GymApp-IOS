//
//  WorkoutView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//
import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var stateViewModel = HomeStateViewModel()
    @State private var plans: [TrainingPlan] = []
    @State private var selectedPlan = ""
    
    @State private var intensityIndex = IntensityIndex(rawValue: UserDefaultsUtils.shared.getIntensity())!
    @State private var weightUnit = WeightUnit(rawValue: UserDefaultsUtils.shared.getWeightUnit())!
    
    @State private var showNewWorkoutAlert = false

   
    let plansDatabaseHelper = PlansDataBaseHelper()
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Backgroundimage(geometry: geometry, imageName: "workout_icon")
                VStack {
                    if stateViewModel.showLastWorkout {
                        NavigationLink(
                            destination: HistoryDetailsView(viewModel: HistoryDetailsViewModel(historyElement: viewModel.workoutHistoryElement))
                                .onDisappear() {
                                    viewModel.loadLastWorkout(stateViewModel: stateViewModel)
                                },
                            label: { VStack(alignment: .center, spacing: 10) {
                                Text("Last workout:")
                                    .foregroundStyle(Color.TextColorPrimary)
                                    .font(.system(size: 20, weight: .bold))
                                    .multilineTextAlignment(.center)
                                
                                VStack {
                                    Text(viewModel.workoutHistoryElement.planName)
                                        .foregroundStyle(Color.TextColorPrimary)
                                        .font(.system(size: 18))
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 1)
                                    
                                    HStack {
                                        Text(viewModel.workoutHistoryElement.formattedDate)
                                            .foregroundStyle(Color.TextColorPrimary)
                                            .font(.system(size: 18, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.leading, 10)
                                        
                                        Text(viewModel.workoutHistoryElement.routineName)
                                            .foregroundStyle(Color.TextColorPrimary)
                                            .font(.system(size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.trailing, 10)
                                    }
                                    .padding(.bottom, 5)
                                    .padding(.horizontal, 25)
                                }
                                .cornerRadius(8)
                                .shadow(radius: 2)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity)

                                
                                Divider()
                                    .frame(maxWidth: .infinity, maxHeight: 2)
                                    .background(Color(.systemGray6))
                            }
                                
                            .frame(maxWidth: .infinity)
                            }
                        )
                    }
                    
                    VStack(alignment: .center) {
                        Menu {
                            Picker(selection: $selectedPlan) {
                                ForEach(plans, id: \.self) { plan in
                                    Text(plan.name).tag(plan.description)
                                }
                            } label: {}
                            .frame(minWidth: 100, minHeight: 30)
                            .clipped()
                            .onChange(of: selectedPlan) { _, plan in
                                UserDefaults.standard.setValue(plan, forKey: Constants.SELECTED_PLAN_NAME)
                            }
                            .disabled(!stateViewModel.isWorkoutEnded)
                        } label: {
                            HStack {
                                Text(selectedPlan)
                                    .font(.system(size: 20))
                                Image(systemName: "chevron.up.chevron.down")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                    .padding(.horizontal, 12)
                    
                    Spacer()
                    
                    //MARK: Two buttons (Return to workout and Start Workout)
                    VStack(spacing: 20) {
                        if !stateViewModel.isWorkoutEnded {
                            Button(action: {
                                if selectedPlan == Constants.NO_PLAN_NAME {
                                    stateViewModel.startNoPlanWorkout = true
                                } else {
                                    stateViewModel.startWorkout = true
                                }
                            }) {
                                Text("Return to workout")
                                    .foregroundColor(Color.TextColorSecondary)
                                    .font(.system(size: 18))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 65)
                                    .background(Color.ColorSecondary)
                                    .cornerRadius(20)
                                    .shadow(radius: 2)
                            }
                            .padding(.horizontal, 70)
                        }
                        
                        Button(action: {
                            if stateViewModel.isWorkoutEnded {
                                if selectedPlan == Constants.NO_PLAN_NAME {
                                    stateViewModel.startNoPlanWorkout = true
                                } else {
                                    stateViewModel.openStartWorkoutSheet = true
                                }
                            } else {
                                showNewWorkoutAlert = true
                            }
                        }) {
                            Text("Start Workout")
                                .foregroundColor(Color.TextColorButton)
                                .font(.system(size: 18))
                                .frame(maxWidth: .infinity)
                                .frame(height: 65)
                                .background(Color.ColorPrimary)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 70)
                        .padding(.bottom, 80)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear() {
                SettingsView.applyTheme(theme: UserDefaultsUtils.shared.getTheme())
                initPickerData()
                viewModel.loadLastWorkout(stateViewModel: stateViewModel)
                if !plans.isEmpty {
                    initPickerChoice()
                }
                stateViewModel.isWorkoutEnded = UserDefaults.standard.bool(forKey: Constants.IS_WORKOUT_SAVED_KEY)
            }
            .sheet(isPresented: $stateViewModel.openStartWorkoutSheet) {
                StartWorkoutSheetView(planName: selectedPlan, homeStateViewModel: stateViewModel)
            }
            .fullScreenCover(isPresented: Binding(get: {
                stateViewModel.startWorkout || stateViewModel.startNoPlanWorkout
            }, set: { newValue in
                if !newValue {
                    stateViewModel.startWorkout = false
                    stateViewModel.startNoPlanWorkout = false
                }
            })) {
                if stateViewModel.startWorkout {
                    WorkoutView(
                        viewModel: 
                            WorkoutViewModel(
                                planName: selectedPlan,
                                routineName: UserDefaults.standard.string(forKey: Constants.UNFINISHED_WORKOUT_ROUTINE_NAME) ?? "Error routine name",
                                date: UserDefaults.standard.string(forKey: Constants.DATE) ?? CustomDate.getCurrentDate()),
                        homeStateViewModel: stateViewModel
                        )
                } else if stateViewModel.startNoPlanWorkout {
                    NoPlanWorkoutView(
                        viewModel:
                            NoPlanWorkoutViewModel(
                                planName: selectedPlan,
                                date: UserDefaults.standard.string(forKey: Constants.DATE) ?? CustomDate.getCurrentDate(),
                                intensityIndex: intensityIndex,
                                weightUnit: weightUnit),
                        homeStateViewModel: stateViewModel)
                }
            }
            .toast(isShowing: $stateViewModel.showToast, message: stateViewModel.toastMessage)
            .alert(isPresented: $showNewWorkoutAlert) {
                Alert(title: Text("Warning"),
                      message: Text("You have unsaved workout. Are you sure you want to start a new one?"),
                      primaryButton: .destructive(Text("YES")) {
                    stateViewModel.isWorkoutEnded = true
                        if selectedPlan == Constants.NO_PLAN_NAME {
                            stateViewModel.startNoPlanWorkout = true
                        } else {
                            stateViewModel.openStartWorkoutSheet = true
                        }
                      },
                      secondaryButton: .cancel()
                )
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
        }
    }
    
    private func initPickerChoice() {
        guard let selectedPlan = UserDefaults.standard.string(forKey: Constants.SELECTED_PLAN_NAME) else {
            self.selectedPlan = Constants.NO_PLAN_NAME
            return
        }
        self.selectedPlan = selectedPlan
    }
    private func initPickerData() {
        plans = plansDatabaseHelper.getPlans()
        plans.insert(TrainingPlan(name: Constants.NO_PLAN_NAME), at: 0)
    }
    
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


