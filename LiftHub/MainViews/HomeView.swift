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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                //Backgroundimage(geometry: geometry, imageName: "workout_icon")
                VStack {
                    if stateViewModel.showLastWorkout {
                        NavigationLink(
                            destination: HistoryDetailsView(viewModel: HistoryDetailsViewModel(historyElement: viewModel.workoutHistoryElement))
                                .onDisappear() {
                                    viewModel.loadLastWorkout(stateViewModel: stateViewModel)
                                },
                            label: {
                                lastWorkoutView(homeViewModel: viewModel, homeStateViewModel: stateViewModel)
                                    .id(viewModel.workoutHistoryElement)
                            }
                        )
                    }
                    
                    Spacer()
                    
                    //MARK: Two buttons (Return to workout and Start Workout)
                    VStack(spacing: 20) {
                        if !UserDefaultsUtils.shared.getHasWorkoutEnded() {
                            Button(action: {
                                if viewModel.unsavedWorkoutPlanName == Constants.NO_PLAN_NAME {
                                    stateViewModel.startNoPlanWorkout = true
                                } else {
                                    stateViewModel.startWorkout = true
                                }
                            }) {
                                Text("Return to workout")
                                    .foregroundColor(Color.TextColorTetiary)
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
                            if UserDefaultsUtils.shared.getHasWorkoutEnded() {
                                /* if viewModel.unsavedWorkoutPlanName == Constants.NO_PLAN_NAME {
                                 stateViewModel.startNoPlanWorkout = true
                                 } else { */
                                stateViewModel.openStartWorkoutSheet = true
                                // }
                            } else {
                                stateViewModel.activeAlert = .newWorkout
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
                viewModel.loadLastWorkout(stateViewModel: stateViewModel)
                UserDefaultsUtils.shared.setHasWorkoutEnded(UserDefaultsUtils.shared.getWorkoutSaved())
                viewModel.getUnsavedWorkoutPlanName()
            }
            .sheet(isPresented: $stateViewModel.openStartWorkoutSheet) {
                StartWorkoutSheetView(homeStateViewModel: stateViewModel)
                    .onDisappear {
                        viewModel.loadLastWorkout(stateViewModel: stateViewModel)
                        viewModel.getUnsavedWorkoutPlanName()
                    }
                    .presentationDetents([.medium, .large])
            }
            .fullScreenCover(isPresented: Binding(get: {
                stateViewModel.startWorkout || stateViewModel.startNoPlanWorkout
            }, set: { newValue in
                if !newValue {
                    stateViewModel.startWorkout = false
                    stateViewModel.startNoPlanWorkout = false
                }
            }),
                onDismiss: {
                    viewModel.getUnsavedWorkoutPlanName()
                    viewModel.loadLastWorkout(stateViewModel: stateViewModel)
            }
            ) {
                if stateViewModel.startWorkout {
                    WorkoutView(
                        viewModel:
                            WorkoutViewModel(
                                planName: viewModel.unsavedWorkoutPlanName,
                                routineName: UserDefaultsUtils.shared.getUnfinishedRoutineName(),
                                date: UserDefaultsUtils.shared.getDate(),
                                intensityIndex: viewModel.intensityIndex,
                                weightUnit: viewModel.weightUnit),
                        homeStateViewModel: stateViewModel
                    )
                } else if stateViewModel.startNoPlanWorkout {
                    NoPlanWorkoutView(
                        viewModel:
                            NoPlanWorkoutViewModel(
                                planName: viewModel.unsavedWorkoutPlanName,
                                date: UserDefaultsUtils.shared.getDate(),
                                intensityIndex: viewModel.intensityIndex,
                                weightUnit: viewModel.weightUnit))
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
        }
    }
    
    
}

private struct lastWorkoutView: View {
    @StateObject var viewModel = LastWorkoutViewModel()
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var homeStateViewModel: HomeStateViewModel
    @State private var showOptionsDialog = false
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .center, spacing: 10) {
                Text("Last workout:")
                    .foregroundStyle(Color.TextColorPrimary)
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                
                VStack {
                    Text(homeViewModel.workoutHistoryElement.planName)
                        .foregroundStyle(Color.TextColorPrimary)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 1)
                    
                    HStack {
                        Text(homeViewModel.workoutHistoryElement.formattedDate)
                            .foregroundStyle(Color.TextColorPrimary)
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.leading, 10)
                        
                        Text(homeViewModel.workoutHistoryElement.routineName)
                            .foregroundStyle(Color.TextColorPrimary)
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 10)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
                    .padding(.bottom, 5)
                    .padding(.horizontal, 20)
                }
                .cornerRadius(8)
                .shadow(radius: 2)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .id(homeViewModel.workoutHistoryElement.rawDate)
                
                Divider()
                    .frame(maxWidth: .infinity, maxHeight: 2)
                    .background(Color(.systemGray6))
            }
            .frame(maxWidth: .infinity)
            
            Menu {
                NavigationLink (
                    destination: EditHistoryDetailsView(historyElementViewModel: HistoryElementViewModel(
                        historyElement: homeViewModel.workoutHistoryElement,
                        position: 0,
                        showToast: viewModel.showToast,
                        toastMessage: viewModel.toastMessage))
                    .onDisappear() {},
                    label: {
                        HStack {
                            Text("Edit")
                                .foregroundColor(Color.accentColor)
                            Image(systemName: "square.and.pencil")
                                .padding()
                                .foregroundColor(Color.accentColor)
                            
                        }
                    }
                )
                
                Button(role: .destructive, action: {
                    homeStateViewModel.activeAlert = .deleteFromHistory
                }) {
                    HStack {
                        Text("Delete")
                            .foregroundColor(Color.red)
                        Image(systemName: "trash")
                            .padding()
                            .foregroundColor(Color.red)
                    }
                    .foregroundStyle(Color.red)
                }
                
            } label: {
                Button(action: {
                }) {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .frame(width: 15, height: 3)
                        .padding()
                        .rotationEffect(.degrees(90))
                }
                .frame(width: 30, height: 20)
                .background(Color.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .onTapGesture {
            showOptionsDialog = true
        }
        .alert(item: $homeStateViewModel.activeAlert) { alertType in
            switch alertType {
            case .newWorkout:
                return Alert(title: Text("Warning"),
                             message: Text("You have unsaved workout. Are you sure you want to start a new one?"),
                             primaryButton: .destructive(Text("YES")) {
                    UserDefaultsUtils.shared.setHasWorkoutEnded(true)
                    if homeViewModel.unsavedWorkoutPlanName == Constants.NO_PLAN_NAME {
                        homeStateViewModel.startNoPlanWorkout = true
                    } else {
                        homeStateViewModel.openStartWorkoutSheet = true
                    }
                },
                             secondaryButton: .cancel()
                )
            case .deleteFromHistory:
                return Alert(
                    title: Text("Warning"),
                    message: Text("Are you sure you want to delete \(homeViewModel.workoutHistoryElement.routineName) from \(homeViewModel.workoutHistoryElement.formattedDate)?"),
                    primaryButton: .destructive(Text("OK")) {
                        viewModel.deleteFromHistory(rawDate: homeViewModel.workoutHistoryElement.rawDate)
                        homeViewModel.loadLastWorkout(stateViewModel: homeStateViewModel)
                    },
                    secondaryButton: .cancel()
                )
            }
            
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


