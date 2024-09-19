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
        GeometryReader { geometry  in
            VStack {
                // Back button as ZStack
                HStack {
                    ZStack{
                        HStack{
                            Button(action: {
                                // Dismiss the current view to go back
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            Spacer()
                        }
                        .padding(.leading, 30) // Add some padding to keep it away from the edge
                        
                        Text(workoutHistoryElement.routineName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.TextColorPrimary)
                    }
                }
                
                EditHistoryDetailsListView(workout: $workoutDraft, showToast: $showToast, toastMessage: $toastMessage)
                
                
                // Horizontal layout for buttons
                HStack(spacing: 10) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(Color.TextColorSecondary)
                            .frame(alignment: .center)
                    }
                    .frame(width: 100, height: 45)
                    .background(Color.ColorSecondary)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 2)
                    
                    Spacer()
                    
                    Button(action: {
                        editHistoryDetails()
                    }) {
                        Text("Save")
                            .foregroundColor(Color.TextColorButton)

                    }
                    .frame(width: 100, height: 45)
                    .background(Color.colorPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
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
            .toast(isShowing: $showToast, message: toastMessage)
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


