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
    @Binding var closeStartWorkoutSheet: Bool
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
    
    var body: some View {
        GeometryReader { geometry  in
            VStack {
                // Back button as ZStack
                HStack {
                    ZStack {
                        // HStack to position the back button on the left
                        HStack {
                            Button(action: {
                                // Dismiss the current view to go back
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .padding(.leading, 30) // Padding to keep the button away from the edge
                            
                            Spacer() // Pushes the button to the left
                        }
                        
                        // Centered TextField
                        HStack {
                            Spacer() // Push the TextField to the center
                            
                            TextField("Enter workout name", text: $routineName)
                                .padding()
                                .background(Color.ShadowColor)
                                .cornerRadius(10)
                                .frame(maxWidth: 250)
                                .multilineTextAlignment(.center)
                            
                            Spacer() // Push the TextField to the center
                        }
                    }
                }
                .padding(.bottom, 10)
                
                NoPlanWorkoutListView(workout: $workoutDraft, showToast: $showToast, toastMessage: $toastMessage, intensityIndex: intensityIndex, weightUnit: weightUnit)
                
                // Horizontal layout for buttons
                HStack(spacing: 90) {
                    Button(action: {
                        showCancelAlert = true
                    }) {
                        Text("Cancel")
                            .foregroundColor(Color.TextColorSecondary)
                            .frame(alignment: .center)
                    }
                    .frame(width: 100, height: 45)
                    .background(Color.ColorSecondary)
                    .cornerRadius(20)
                    .shadow(radius: 3)
                    
                    //                // Timer button with ZStack for the icon
                    //                ZStack {
                    //                    Button(action: {
                    //                        // Timer action
                    //                    }) {
                    //                        Image(systemName: "timer")
                    //                            .resizable()
                    //                            .frame(width: 35, height: 35)
                    //                    }
                    //                    .frame(width: 60, height: 54)
                    //                    .background(Color.black.opacity(0.7))
                    //                    .cornerRadius(8)
                    //                }
                    

                    
                    Button(action: {
                        saveWorkoutToHistory(date: date)
                    }) {
                        Text("Save")
                            .foregroundColor(Color.TextColorButton)

                    }
                    .frame(width: 100, height: 45)
                    .background(Color.ColorPrimary)
                    .cornerRadius(20)
                    .shadow(radius: 3)
                }
                .padding(.top, 32)
                .padding(.horizontal, 50)
                
                Spacer() // To push content up
                
                // Guideline equivalent (use a Spacer with fixed height)
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear(){
                loadRoutine()
            }
            .onDisappear(){
                if !isWorkoutFinished {
                    isWorkoutEnded = false
                    saveWorkoutToFile()
                }
                closeStartWorkoutSheet = true
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
        }
    }
    
    private func loadRoutine() {
        if !isWorkoutSaved {
            initRecoveredWorkoutData()
        } else {
            workoutDraft.append((workoutExerciseDraft: WorkoutExerciseDraft(
                name: "",
                pause: "",
                pauseUnit: TimeUnit.min,
                series: "",
                reps: "",
                intensity: "",
                intensityIndex: intensityIndex,
                pace: "",
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
        guard let recoveredWorkout = loadWorkoutFromFile() else {
            print("recovered workout was null in WorkoutView")
            return
        }
        for (index, exercise) in recoveredWorkout.enumerated() {
            workoutDraft[index].workoutExerciseDraft.note = exercise.workoutExerciseDraft.note
            for (setIndex, set) in exercise.workoutSeriesDraftList.enumerated() {
                workoutDraft[index].workoutSeriesDraftList[setIndex].actualReps = set.actualReps
                workoutDraft[index].workoutSeriesDraftList[setIndex].actualLoad = set.actualLoad
                workoutDraft[index].workoutSeriesDraftList[setIndex].actualIntensity = set.actualIntensity
            }
        }
    }
    
    private func saveWorkoutToHistory(date: String) {
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
            } catch {
                print("Error in WorkoutExercise in saving workout \(error)")
                return
            }
        }
        workoutHistoryDatabaseHelper.checkForeignKeysEnabled()
        workoutHistoryDatabaseHelper.addExercises(workout: workout, date: date, planName: planName, routineName: routineName)
        UserDefaults.standard.setValue(true, forKey: Constants.IS_WORKOUT_SAVED_KEY)
        isWorkoutEnded = true
        isWorkoutFinished = true
        showWorkoutSavedToast = true
        savedWorkoutToastMessage = "Workout Saved!"
        presentationMode.wrappedValue.dismiss()
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
        NoPlanWorkoutView(planName: "Plan", date: "", closeStartWorkoutSheet: $closeWorkutSheet, isWorkoutEnded: $isWorkoutEnded, showWorkoutSavedToast: $showToast, savedWorkoutToastMessage: $toastMessage, intensityIndex: IntensityIndex.RPE, weightUnit: WeightUnit.kg)
    }
}


