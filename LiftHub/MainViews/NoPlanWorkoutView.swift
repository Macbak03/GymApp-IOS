//
//  NoPlanWorkoutView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 19/09/2024.
//

import SwiftUI

struct NoPlanWorkoutView: View {
    let planName: String
    @State private var routineName: String = ""
    let date: String
    @Binding var isWorkoutEnded: Bool
    @Binding var showWorkoutSavedToast: Bool
    @Binding var savedWorkoutToastMessage: String
    
    let intensityIndex: IntensityIndex
    let weightUnit: WeightUnit
    
    @Environment(\.presentationMode) var presentationMode // Allows us to dismiss this view
    @Environment(\.scenePhase) var scenePhase
    
    @State private var workoutDraft: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])] = []
    private let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    private let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
    
    private let isWorkoutSaved = UserDefaults.standard.bool(forKey: Constants.IS_WORKOUT_SAVED_KEY)
    
    @State private var isWorkoutFinished = false
    
    @State private var showCancelAlert = false
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @FocusState private var isWorkoutNameFocused: Bool
    @State private var showNameError = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                // Back button as ZStack
                HStack {
                    HStack {
                        Spacer() // Push the TextField to the center
                        
                        TextField("Enter workout name", text: $routineName)
                            .font(.system(size: 18))
                            .frame(height: 40)
                            .background(Color.ShadowColor)
                            .cornerRadius(10)
                            .padding(.horizontal, 35)
                            .multilineTextAlignment(.center)
                            .focused($isWorkoutNameFocused)
                            .onChange(of: isWorkoutNameFocused) { focused in
                                validateWorkoutName(focused: focused)
                            }
                        
                        Spacer() // Push the TextField to the center
                    }
                    if showNameError {
                        HStack {
                            Spacer()
                            Image(systemName: "exclamationmark.circle.fill")
                                .resizable()
                                .foregroundColor(.red)
                                .frame(width: 25, height: 25)
                        }
                        .padding(.trailing, 80)
                    }
                }
                .padding(.bottom, 10)
                
                NoPlanWorkoutListView(workout: $workoutDraft, showToast: $showToast, toastMessage: $toastMessage, intensityIndex: intensityIndex, weightUnit: weightUnit)
                
            }
            .onAppear(){
                loadRoutine()
            }
            .onDisappear(){
                if !isWorkoutFinished {
                    isWorkoutEnded = false
                    saveWorkoutToFile()
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    saveWorkoutToFile()
                }
            }
            .alert(isPresented: $showCancelAlert) {
                Alert(
                    title: Text("Warning"),
                    message: Text("Workout won't be saved. Do you want to cancel?"),
                    primaryButton: .destructive(Text("Yes")) {
                        UserDefaults.standard.setValue(true, forKey: Constants.IS_WORKOUT_SAVED_KEY)
                        isWorkoutEnded = true
                        isWorkoutFinished = true
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
            .toast(isShowing: $showToast, message: toastMessage)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: {
                            showCancelAlert = true
                        }) {
                            Text("Cancel")
                                .foregroundStyle(Color.red)
                        }
                        Button(action: {
                            saveWorkoutToHistory(date: date)
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
        }
    }
    
    private func loadRoutine() {
        if !isWorkoutSaved && !isWorkoutEnded {
            initRecoveredWorkoutData()
        } else {
            workoutDraft.append((workoutExerciseDraft: WorkoutExerciseDraft(
                name: "",
                pause: "0",
                pauseUnit: TimeUnit.min,
                series: "0",
                reps: "0",
                intensity: "0",
                intensityIndex: intensityIndex,
                pace: "0000",
                note: ""),
                                 workoutSeriesDraftList: [WorkoutSeriesDraft(
                                    actualReps: "",
                                    actualLoad: "",
                                    loadUnit: weightUnit,
                                    intensityIndex: intensityIndex,
                                    actualIntensity: "")]
            ))
        }
    }
    
    private func saveWorkoutToFile() {
        let workoutList = workoutDraft.map {
            WorkoutDraft(workoutExerciseDraft: $0.workoutExerciseDraft, workoutSeriesDraftList: $0.workoutSeriesDraftList)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(workoutList)
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentDirectory.appendingPathComponent("workout.json")
                try jsonData.write(to: fileURL)
                UserDefaults.standard.setValue(false, forKey: Constants.IS_WORKOUT_SAVED_KEY)
                UserDefaults.standard.setValue(routineName, forKey: Constants.UNFINISHED_WORKOUT_ROUTINE_NAME)
                UserDefaults.standard.setValue(date, forKey: Constants.DATE)
                print("Workout data saved at: \(fileURL)")
            }
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    private func loadWorkoutFromFile() -> [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])]? {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("workout.json")
            
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let workoutList = try decoder.decode([WorkoutDraft].self, from: data)
                return workoutList.map { ($0.workoutExerciseDraft, $0.workoutSeriesDraftList) }
            } catch {
                print("Error loading workout: \(error)")
            }
        }
        return nil
    }
    
    private func initRecoveredWorkoutData() {
        routineName = UserDefaults.standard.string(forKey: Constants.UNFINISHED_WORKOUT_ROUTINE_NAME) ?? ""
        guard let recoveredWorkout = loadWorkoutFromFile() else {
            print("recovered workout was null in NoPlanWorkoutView")
            return
        }
        workoutDraft = recoveredWorkout
    }
    
    private func saveWorkoutToHistory(date: String) {
        do {
            try handleWorkoutNameException()
        } catch let error as ValidationException {
            showNameError = true
            showToast = true
            toastMessage = error.message
            return
        } catch {
            toastMessage = "An unexpected error occured \(error)"
            return
        }
        var workout = [(workoutExercise: WorkoutExercise, exerciseSeries: [WorkoutSeries])]()
        var series = [WorkoutSeries]()
        for (index, pair) in workoutDraft.enumerated() {
            let loadUnit = pair.workoutSeriesDraftList[0].loadUnit
            let exerciseDraft = ExerciseDraft(
                name: pair.workoutExerciseDraft.name,
                pause: pair.workoutExerciseDraft.pause,
                pauseUnit: pair.workoutExerciseDraft.pauseUnit,
                load: "0",
                loadUnit: loadUnit,
                series: pair.workoutExerciseDraft.series,
                reps: pair.workoutExerciseDraft.reps,
                intensity: pair.workoutExerciseDraft.intensity,
                intensityIndex: pair.workoutExerciseDraft.intensityIndex,
                pace: pair.workoutExerciseDraft.pace,
                wasModified: false)
            for (index, setDraft) in pair.workoutSeriesDraftList.enumerated() {
                do {
                    let set = try setDraft.toWorkoutSeries(seriesCount: (index + 1))
                    series.append(set)
                } catch let error as ValidationException {
                    showToast = true
                    toastMessage = error.message
                    return
                } catch {
                    print("Unexpected error occured when saving workout: \(error)")
                    return
                }
            }
            do {
                let exercise = try exerciseDraft.toExercise()
                workout.append((workoutExercise: WorkoutExercise(exercise: exercise, exerciseCount: (index + 1), note: pair.workoutExerciseDraft.note), exerciseSeries: series))
                series.removeAll()
            } catch let error as ValidationException {
                showToast = true
                toastMessage = error.message
                return
            } catch {
                print("Error in WorkoutExercise when saving workout \(error)")
                return
            }
        }
        workoutHistoryDatabaseHelper.addExercises(workout: workout, date: date, planName: planName, routineName: routineName)
        UserDefaults.standard.setValue(nil, forKey: Constants.DATE)
        UserDefaults.standard.setValue(true, forKey: Constants.IS_WORKOUT_SAVED_KEY)
        isWorkoutEnded = true
        isWorkoutFinished = true
        showWorkoutSavedToast = true
        savedWorkoutToastMessage = "Workout Saved!"
        presentationMode.wrappedValue.dismiss()
    }
    
    private func handleWorkoutNameException() throws {
        if routineName.isEmpty {
            throw ValidationException(message: "Workout name cannot be empty")
        }
    }
    
    private func validateWorkoutName(focused: Bool) {
        if !focused {
            do {
                try handleWorkoutNameException()
            } catch let error as ValidationException {
                showNameError = true
                showToast = true
                toastMessage = error.message
            } catch {
                toastMessage = "An unexpected error occured \(error)"
            }
        } else {
            showNameError = false
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
        NoPlanWorkoutView(planName: "Plan", date: "", isWorkoutEnded: $isWorkoutEnded, showWorkoutSavedToast: $showToast, savedWorkoutToastMessage: $toastMessage, intensityIndex: IntensityIndex.RPE, weightUnit: WeightUnit.kg)
    }
}


