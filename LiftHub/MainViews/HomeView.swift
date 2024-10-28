//
//  WorkoutView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 07/09/2024.
//
import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State var routines: [TrainingPlanElement] = []
    @State private var plans: [TrainingPlan] = []
    @State private var selectedPlan = ""
    @State private var openStartWorkoutSheet = false
    private var isWorkoutSaved = UserDefaults.standard.bool(forKey: Constants.IS_WORKOUT_SAVED_KEY)
    
    @State private var startWorkout = false
    @State private var startNoPlanWorkout = false
    @State private var closeStartWorkoutSheet = false
    @State private var isWorkoutEnded = true
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var showLastWorkout = false
    @State private var lastWorkoutPlanName = "Plan"
    @State private var lastWorkoutDate = "Date"
    @State private var lastWorkoutRoutineName = "Routine"
    @State private var lastWorkoutRawDate = ""
    
    @State private var openLastWorkout = false
    
    @State private var intensityIndex = IntensityIndex(rawValue: UserDefaultsUtils.shared.getIntensity())!
    @State private var weightUnit = WeightUnit(rawValue: UserDefaultsUtils.shared.getWeight())!
    
    @State private var showNewWorkoutAlert = false

   
    let plansDatabaseHelper = PlansDataBaseHelper()
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Backgroundimage(geometry: geometry, imageName: "workout_icon")
                VStack {
                    VStack(alignment: .center) {
//                        Text("Current plan:")
//                            .foregroundStyle(Color.TextColorPrimary)
//                            .font(.system(size: 25, weight: .bold))
//                            .multilineTextAlignment(.center)
                        // This Spinner is custom, so let's just place a placeholder
                        Picker("Training Plans", selection: $selectedPlan) {
                            ForEach(plans, id: \.self) { plan in
                                Text(plan.name).tag(plan.description)
                            }
                        }
                        .frame(minWidth: 100, minHeight: 30)
                        .clipped()
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedPlan) { plan in
                            UserDefaults.standard.setValue(plan, forKey: Constants.SELECTED_PLAN_NAME)
                        }
                        .disabled(!isWorkoutEnded)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                    .padding(.horizontal, 12)
                    
                    if showLastWorkout {
                        NavigationLink(
                            destination: HistoryDetailsView(rawDate: lastWorkoutRawDate, date: lastWorkoutDate, planName: lastWorkoutPlanName, routineName: lastWorkoutRoutineName),
                            label: { VStack(alignment: .center, spacing: 10) {
                                Text("Last workout:")
                                    .foregroundStyle(Color.TextColorPrimary)
                                    .font(.system(size: 20, weight: .bold))
                                    .multilineTextAlignment(.center)
                                
                                VStack {
                                    Text(lastWorkoutPlanName)
                                        .foregroundStyle(Color.TextColorPrimary)
                                        .font(.system(size: 18))
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 1)
                                    
                                    HStack {
                                        Text(lastWorkoutDate)
                                            .foregroundStyle(Color.TextColorPrimary)
                                            .font(.system(size: 18, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.leading, 10)
                                        
                                        Text(lastWorkoutRoutineName)
                                            .foregroundStyle(Color.TextColorPrimary)
                                            .font(.system(size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.trailing, 10)
                                    }
                                    .padding(.bottom, 5)
                                    .padding(.horizontal, 25)
                                }
                                //.background(Color.BackgroundColorList)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity)
//                                .onTapGesture {
//                                    openLastWorkout = true
//                                }
                                
                                Divider()
                                    .frame(maxWidth: .infinity, maxHeight: 2)  // Vertical line, adjust height as needed
                                    .background(Color(.systemGray6)) // Set color for the line
                            }
                                
                            .frame(maxWidth: .infinity)
                            }
                        )
                    }
                    
                    Spacer()
                    
                    // Two buttons (Return to workout and Start Workout)
                    VStack(spacing: 20) {
                        if !isWorkoutEnded {
                            Button(action: {
                                if selectedPlan == Constants.NO_PLAN_NAME {
                                    startNoPlanWorkout = true
                                } else {
                                    startWorkout = true
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
                            if isWorkoutEnded {
                                if selectedPlan == Constants.NO_PLAN_NAME {
                                    startNoPlanWorkout = true
                                } else {
                                    openStartWorkoutSheet = true
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
                loadLastWorkout()
                if !plans.isEmpty {
                    initPickerChoice()
                }
                isWorkoutEnded = UserDefaults.standard.bool(forKey: Constants.IS_WORKOUT_SAVED_KEY)
            }
            .sheet(isPresented: $openStartWorkoutSheet) {
                StartWorkoutSheetView(planName: selectedPlan, isWorkoutEnded: $isWorkoutEnded, showWorkoutSavedToast: $showToast, savedWorkoutToastMessage: $toastMessage)
            }
            .fullScreenCover(isPresented: Binding(get: {
                startWorkout || openLastWorkout || startNoPlanWorkout
            }, set: { newValue in
                if !newValue {
                    startWorkout = false
                    openLastWorkout = false
                    startNoPlanWorkout = false
                }
            }), onDismiss: {
                loadLastWorkout()
            }) {
                if startWorkout {
                    WorkoutView(planName: selectedPlan,
                                routineName: UserDefaults.standard.string(forKey: Constants.UNFINISHED_WORKOUT_ROUTINE_NAME) ?? "Error routine name",
                                date: UserDefaults.standard.string(forKey: Constants.DATE) ?? CustomDate.getDate(),
                                closeStartWorkoutSheet: $closeStartWorkoutSheet,
                                isWorkoutEnded: $isWorkoutEnded,
                                showWorkoutSavedToast: $showToast,
                                savedWorkoutToastMessage: $toastMessage)
                } else if openLastWorkout {
                    HistoryDetailsView(rawDate: lastWorkoutRawDate, date: lastWorkoutDate, planName: lastWorkoutPlanName, routineName: lastWorkoutRoutineName)
                } else if startNoPlanWorkout {
                    NoPlanWorkoutView(planName: selectedPlan,
                                      date: UserDefaults.standard.string(forKey: Constants.DATE) ?? CustomDate.getDate(),
                                      isWorkoutEnded: $isWorkoutEnded,
                                      showWorkoutSavedToast: $showToast,
                                      savedWorkoutToastMessage: $toastMessage,
                                      intensityIndex: intensityIndex,
                                      weightUnit: weightUnit)
                }
            }
            .toast(isShowing: $showToast, message: toastMessage)
            .alert(isPresented: $showNewWorkoutAlert) {
                Alert(title: Text("Warning"),
                      message: Text("You have unsaved workout. Are you sure you want to start a new one?"),
                      primaryButton: .destructive(Text("YES")) {
                        isWorkoutEnded = true
                        if selectedPlan == Constants.NO_PLAN_NAME {
                            startNoPlanWorkout = true
                        } else {
                            openStartWorkoutSheet = true
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
    
    private func loadLastWorkout(){
        let historyDatabaseHelper = WorkoutHistoryDataBaseHelper()
        if historyDatabaseHelper.isTableNotEmpty() {
            showLastWorkout = true
        } else {
            showLastWorkout = false
        }
        let lastWorkout = historyDatabaseHelper.getLastWorkout()
        guard let workoutPlanName = lastWorkout[0] else {
            return
        }
        guard let workoutDate = lastWorkout[1] else {
            return
        }
        guard let workoutRoutineName = lastWorkout[2] else {
            return
        }
        lastWorkoutPlanName = workoutPlanName
        lastWorkoutRawDate = workoutDate
        lastWorkoutDate = CustomDate.getFormattedDate(savedDate: workoutDate)
        lastWorkoutRoutineName = workoutRoutineName
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


