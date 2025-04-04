//
//  EditHistoryDetailsViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 22/11/2024.
//

import Foundation

class EditHistoryDetailsViewModel: ObservableObject {
    @Published var workoutDraft: [WorkoutDraft] = []
    @Published var showToast = false
    @Published var toastMessage = ""
    
    @Published var planName = ""
    
    @Published var historySuccessfullyEdited = false
    
    @Published var repeatWorkout = false
    
    private let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    private let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
    
    @Published var intensityIndex = IntensityIndex(rawValue: UserDefaultsUtils.shared.getIntensity())!
    @Published var weightUnit = WeightUnit(rawValue: UserDefaultsUtils.shared.getWeightUnit())!
    
    func loadRoutine(historyElementViewModel: HistoryElementViewModel) {
        planName = historyElementViewModel.historyElement.planName
        let rawDate = historyElementViewModel.historyElement.rawDate
        let workoutExercises = workoutHistoryDatabaseHelper.getWorkoutExercises(date: historyElementViewModel.historyElement.rawDate, routineName: historyElementViewModel.historyElement.routineName, planName: historyElementViewModel.historyElement.planName)
        for workoutExercise in workoutExercises {
            guard let exerciseId = workoutHistoryDatabaseHelper.getExerciseID(date: rawDate, exerciseName: workoutExercise.name) else {
                print("exercise id in EditHistoryDetails was null")
                return
            }
            let seriesList = workoutSeriesDatabaseHelper.getSeries(exerciseId: exerciseId)
            workoutDraft.append(WorkoutDraft(workoutExerciseDraft: workoutExercise, workoutSeriesDraftList: seriesList))
        }
    }
    
    func editHistoryDetails(historyElementViewModel: HistoryElementViewModel) {
        let rawDate = historyElementViewModel.historyElement.rawDate
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
        historyElementViewModel.showToast = true
        historyElementViewModel.toastMessage = "Workout Saved!"
        historySuccessfullyEdited = true
    }
    
    private func getWorkoutSeries(groupPosition: Int) throws -> [WorkoutSeries]{
        var series = [WorkoutSeries]()
        for (index, setDraft) in workoutDraft[groupPosition].workoutSeriesDraftList.enumerated() {
            do {
                let set = try setDraft.toWorkoutSeries(seriesCount: (index + 1))
                series.append(set)
            } catch let error as ValidationException {
                throw ValidationException(message: error.message)
            } catch {
                throw ValidationException(message: error.localizedDescription)
            }
        }
        return series
    }
    
    func setToast(errorMessage: String) {
        toastMessage = errorMessage
        showToast = true
    }
}
