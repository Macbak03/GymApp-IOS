//
//  WorkoutViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 23/11/2024.
//

import Foundation
import SwiftUI

class WorkoutViewModel: ObservableObject {
    @Published var workoutDraft: [WorkoutDraft] = []
    @Published var workoutHints: [WorkoutHints] = []
    let planName: String
    let routineName: String
    let date: String
    
    private let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    private let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
    
    init(planName: String, routineName: String, date: String) {
        self.planName = planName
        self.routineName = routineName
        self.date = date
    }
    
    func loadRoutine(isWorkoutSaved: Bool) {
        let exercisesDatabaseHelper = ExercisesDataBaseHelper()
        let plansDatabaseHelper = PlansDataBaseHelper()
        guard let planId = plansDatabaseHelper.getPlanId(planName: planName) else {
            print("planId was null in workoutView")
            return
        }
        let savedRoutine = exercisesDatabaseHelper.getRoutine(routineName: routineName, planId: String(planId))
        for (index, savedExercise) in savedRoutine.enumerated() {
            let exercise = WorkoutExerciseDraft(name: savedExercise.name, pause: savedExercise.pause, pauseUnit: savedExercise.pauseUnit, series: savedExercise.series, reps: savedExercise.reps, loadUnit: savedExercise.loadUnit,intensity: savedExercise.intensity, intensityIndex: savedExercise.intensityIndex, pace: savedExercise.pace, note: "")
            let seriesList: [WorkoutSeriesDraft] = Array(repeating: WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: savedExercise.loadUnit, intensityIndex: savedExercise.intensityIndex, actualIntensity: ""), count: Int(savedExercise.series)!)
            workoutDraft.append(WorkoutDraft(workoutExerciseDraft: exercise, workoutSeriesDraftList: seriesList))
            let savedNotes = workoutHistoryDatabaseHelper.getLastTrainingNotes(planName: planName, routineName: routineName)
            if !savedNotes.isEmpty {
                if index < savedNotes.count {
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
            } else {
                let workoutHint = WorkoutHints(repsHint: savedExercise.reps, weightHint: savedExercise.load, intensityHint: savedExercise.intensity, noteHint: "Note")
                self.workoutHints.append(workoutHint)
            }
                
        }
        if !isWorkoutSaved {
            initRecoveredWorkoutData()
        }
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
    
    private func loadWorkoutFromFile() -> [WorkoutDraft]? {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("workout.json")
            
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let workoutList = try decoder.decode([WorkoutDraft].self, from: data)
                return workoutList.map { WorkoutDraft(workoutExerciseDraft: $0.workoutExerciseDraft, workoutSeriesDraftList:$0.workoutSeriesDraftList) }
            } catch {
                print("Error loading workout: \(error)")
            }
        }
        return nil
    }
    
    func saveWorkoutToFile() {
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
                UserDefaultsUtils.shared.setWorkoutSaved(workoutSaved: false)
                UserDefaultsUtils.shared.setUnfinishedRoutineName(routineName: routineName)
                UserDefaultsUtils.shared.setUnsavedWorkoutPlanName(planName: planName)
                UserDefaultsUtils.shared.setDate(date: date)
                print("Workout data saved at: \(fileURL)")
            }
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    func clearWorkoutData(workoutStateViewModel: WorkoutStateViewModel) {
        UserDefaultsUtils.shared.removeDate()
        UserDefaultsUtils.shared.setHasWorkoutEnded(true)
        UserDefaultsUtils.shared.setWorkoutSaved(workoutSaved: true)
        UserDefaultsUtils.shared.removeUnfinishedRoutineName()
        UserDefaultsUtils.shared.removeUnsavedWorkoutPlanName()
        workoutStateViewModel.isWorkoutFinished = true
    }
    
    func saveWorkoutToHistory(workoutStateViewModel: WorkoutStateViewModel, homeStateViewModel: HomeStateViewModel) {
        var workout = [Workout]()
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
                    if workoutStateViewModel.isSaveClicked {
                        workoutStateViewModel.showToast = true
                        workoutStateViewModel.toastMessage = error.message
                    }
                    return
                } catch {
                    print("Unexpected error occured when saving workout: \(error)")
                    return
                }
            }
            do {
                let exercise = try exerciseDraft.toExercise()
                workout.append(Workout(workoutExercise: WorkoutExercise(exercise: exercise, exerciseCount: (index + 1), note: pair.workoutExerciseDraft.note), exerciseSeriesList: series))
                series.removeAll()
            } catch {
                print("Error in WorkoutExercise in saving workout \(error)")
                return
            }
        }
        workoutHistoryDatabaseHelper.addExercises(workout: workout, date: date, planName: planName, routineName: routineName)
        UserDefaultsUtils.shared.removeDate()
        UserDefaultsUtils.shared.setWorkoutSaved(workoutSaved: true)
        UserDefaultsUtils.shared.setHasWorkoutEnded(true)
        UserDefaultsUtils.shared.removeUnsavedWorkoutPlanName()
        workoutStateViewModel.isWorkoutFinished = true
    }
}
