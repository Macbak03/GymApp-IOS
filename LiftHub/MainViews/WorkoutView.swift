//
//  WorkoutView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 13/09/2024.
//

import SwiftUI
import UIKit

struct WorkoutView: View {
    let planName: String
    let routineName: String
    let date: String
    @Binding var closeStartWorkoutSheet: Bool
    @Binding var isWorkoutEnded: Bool
    @Binding var showWorkoutSavedToast: Bool
    @Binding var savedWorkoutToastMessage: String
    
    
    @Environment(\.presentationMode) var presentationMode // Allows us to dismiss this view
    @Environment(\.scenePhase) var scenePhase
    
    @State private var workoutDraft: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])] = []
    
    @State private var workoutHints: [WorkoutHints] = []
    
    private let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    private let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
    
    private let isWorkoutSaved = UserDefaults.standard.bool(forKey: Constants.IS_WORKOUT_SAVED_KEY)

    @State private var isWorkoutFinished = false
    
    @State private var showCancelAlert = false
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @State private var isSaveClicked = false
    
    var body: some View {
        NavigationStack {
            VStack {
                WorkoutListView(workout: $workoutDraft, workoutHints: $workoutHints, showToast: $showToast, toastMessage: $toastMessage, isSavedClicked: $isSaveClicked)
                
            }
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
            .navigationTitle(routineName)
            .navigationBarTitleDisplayMode(.inline)
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
                            isSaveClicked = true
                            if isSaveClicked {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    saveWorkoutToHistory(date: date)
                                }
                            } else {
                                saveWorkoutToHistory(date: date)
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
        }
    }
    
    private func loadRoutine() {
        let exercisesDatabaseHelper = ExercisesDataBaseHelper()
        let plansDatabaseHelper = PlansDataBaseHelper()
        guard let planId = plansDatabaseHelper.getPlanId(planName: planName) else {
            print("planId was null in workoutView")
            return
        }
        let savedRoutine = exercisesDatabaseHelper.getRoutine(routineName: routineName, planId: String(planId))
        for (index, savedExercise) in savedRoutine.enumerated() {
            let exercise = WorkoutExerciseDraft(name: savedExercise.name, pause: savedExercise.pause, pauseUnit: savedExercise.pauseUnit, series: savedExercise.series, reps: savedExercise.reps, intensity: savedExercise.intensity, intensityIndex: savedExercise.intensityIndex, pace: savedExercise.pace, note: "")
            let seriesList: [WorkoutSeriesDraft] = Array(repeating: WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: savedExercise.loadUnit, intensityIndex: savedExercise.intensityIndex, actualIntensity: ""), count: Int(savedExercise.series)!)
            workoutDraft.append((workoutExerciseDraft: exercise, workoutSeriesDraftList: seriesList))
            let savedNotes = workoutHistoryDatabaseHelper.getLastTrainingNotes(planName: planName, routineName: routineName)
            if !savedNotes.isEmpty {
                let note = savedNotes[index]
                if !note.isEmpty {
                    let workoutHint = WorkoutHints(repsHint: savedExercise.reps, weightHint:           savedExercise.load, intensityHint: savedExercise.intensity, noteHint: note)
                    self.workoutHints.append(workoutHint)
                } else {
                    let workoutHint = WorkoutHints(repsHint: savedExercise.reps, weightHint: savedExercise.load, intensityHint: savedExercise.intensity, noteHint: "Note")
                    self.workoutHints.append(workoutHint)
                }
            } else {
                let workoutHint = WorkoutHints(repsHint: savedExercise.reps, weightHint: savedExercise.load, intensityHint: savedExercise.intensity, noteHint: "Note")
                self.workoutHints.append(workoutHint)
            }
        }
        if !isWorkoutSaved {
            initRecoveredWorkoutData()
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
            if index < workoutDraft.endIndex {
                workoutDraft[index].workoutExerciseDraft.note = exercise.workoutExerciseDraft.note
            } else {
                break
            }
            for (setIndex, set) in exercise.workoutSeriesDraftList.enumerated() {
                if setIndex < workoutDraft[index].workoutSeriesDraftList.endIndex {
                    workoutDraft[index].workoutSeriesDraftList[setIndex].actualReps = set.actualReps
                    workoutDraft[index].workoutSeriesDraftList[setIndex].actualLoad = set.actualLoad
                    workoutDraft[index].workoutSeriesDraftList[setIndex].actualIntensity = set.actualIntensity
                } else {
                    break
                }
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
                    if isSaveClicked {
                        showToast = true
                        toastMessage = error.message
                    }
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
        workoutHistoryDatabaseHelper.addExercises(workout: workout, date: date, planName: planName, routineName: routineName)
        UserDefaults.standard.setValue(nil, forKey: Constants.DATE)
        UserDefaults.standard.setValue(true, forKey: Constants.IS_WORKOUT_SAVED_KEY)
        isWorkoutEnded = true
        isWorkoutFinished = true
        showWorkoutSavedToast = true
        savedWorkoutToastMessage = "Workout Saved!"
        presentationMode.wrappedValue.dismiss()
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
        WorkoutView(planName: "Plan", routineName: "Routine", date: "", closeStartWorkoutSheet: $closeWorkutSheet, isWorkoutEnded: $isWorkoutEnded, showWorkoutSavedToast: $showToast, savedWorkoutToastMessage: $toastMessage)
    }
}

