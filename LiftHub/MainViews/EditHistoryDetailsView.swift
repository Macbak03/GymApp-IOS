//
//  EditHistoryDetailsView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 17/09/2024.
//

import SwiftUI

struct EditHistoryDetailsView: View {
    let workoutHistoryElement: WorkoutHistoryElement
    @Binding var showWorkoutSavedToast: Bool
    @Binding var savedWorkoutToastMessage: String
    @Environment(\.presentationMode) var presentationMode // Allows us to dismiss this view
    @Environment(\.scenePhase) var scenePhase
    
    @State private var workoutDraft: [(workoutExerciseDraft: WorkoutExerciseDraft, workoutSeriesDraftList: [WorkoutSeriesDraft])] = []
    
    private let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    private let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                EditHistoryDetailsListView(workout: $workoutDraft, planName: workoutHistoryElement.planName, showToast: $showToast, toastMessage: $toastMessage)
            }
            .onAppear(){
                loadRoutine()
            }
            .toast(isShowing: $showToast, message: toastMessage)
            .navigationTitle(workoutHistoryElement.routineName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundStyle(Color.red)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        editHistoryDetails()
                    }) {
                        Text("Save")
                    }
                }
            }
        }
    }
    
    private func loadRoutine() {
        let rawDate = workoutHistoryElement.rawDate
        let workoutExercises = workoutHistoryDatabaseHelper.getWorkoutExercises(date: workoutHistoryElement.rawDate, routineName: workoutHistoryElement.routineName, planName: workoutHistoryElement.planName)
        for workoutExercise in workoutExercises {
            guard let exerciseId = workoutHistoryDatabaseHelper.getExerciseID(date: rawDate, exerciseName: workoutExercise.name) else {
                print("exercise id in EditHistoryDetails was null")
                return
            }
            let seriesList = workoutSeriesDatabaseHelper.getSeries(exerciseId: exerciseId)
            workoutDraft.append((workoutExerciseDraft: workoutExercise, workoutSeriesDraftList: seriesList))
        }
    }
    
    private func editHistoryDetails() {
        let rawDate = workoutHistoryElement.rawDate
        let exerciseIds = workoutHistoryDatabaseHelper.getExerciseIdsByDate(date: rawDate)
        for groupPosition in 0..<workoutDraft.count {
            do {
                let workoutSeries = try getWorkoutSeries(groupPosition: groupPosition)
                for (index, set) in workoutSeries.enumerated() {
                    workoutSeriesDatabaseHelper.updateSeriesValues(exerciseId: exerciseIds[groupPosition], setOrder: Int64(index + 1), actualReps: set.actualReps, loadValue: set.load.weight, intensityValue: Int(set.actualIntensity.description)!)
                }
                workoutHistoryDatabaseHelper.updateNotes(date: rawDate, exerciseId: exerciseIds[groupPosition], newNote: workoutDraft[groupPosition].workoutExerciseDraft.note)
            } catch let error as ValidationException {
                showToast = true
                toastMessage = error.message
                return
            } catch {
                print("Unexpected error occured in EditHistoryDetailsView: \(error)")
                return
            }
        }
        showWorkoutSavedToast = true
        savedWorkoutToastMessage = "Workout Saved!"
        presentationMode.wrappedValue.dismiss()
    }
    
    private func getWorkoutSeries(groupPosition: Int) throws -> [WorkoutSeries]{
        var series = [WorkoutSeries]()
        for (index, setDraft) in workoutDraft[groupPosition].workoutSeriesDraftList.enumerated() {
            do {
                let set = try setDraft.toWorkoutSeries(seriesCount: (index + 1))
                series.append(set)
            } catch let error as ValidationException {
                throw ValidationException(message: error.message)
//                showToast = true
//                toastMessage = error.message
            } catch {
                throw ValidationException(message: error.localizedDescription)
            }
        }
        return series
    }
}

struct EditHistoryDetailsView_Previews: PreviewProvider {
    @State static var showToast = true
    @State static var toastMessage: String = ""
    @State static var workoutHistoryElement = WorkoutHistoryElement(planName: "Plan", routineName: "Routine", formattedDate: "17.09.2024", rawDate: "17.09.2024 22:22:22")
    static var previews: some View {
        EditHistoryDetailsView(workoutHistoryElement: workoutHistoryElement, showWorkoutSavedToast: $showToast, savedWorkoutToastMessage: $toastMessage)
    }
}


