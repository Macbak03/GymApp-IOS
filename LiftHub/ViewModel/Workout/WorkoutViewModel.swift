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
    let intensityIndex: IntensityIndex
    let weightUnit: WeightUnit
    
    private let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    private let workoutSeriesDatabaseHelper = WorkoutSeriesDataBaseHelper()
    private var isWorkoutRepeated = false
    
    init(planName: String, routineName: String, date: String, intensityIndex: IntensityIndex, weightUnit: WeightUnit) {
        self.planName = planName
        self.routineName = routineName
        self.date = date
        self.intensityIndex = intensityIndex
        self.weightUnit = weightUnit
    }
    
    init(workoutDraft: [WorkoutDraft], planName: String, routineName: String = "", date: String, intensityIndex: IntensityIndex, weightUnit: WeightUnit) {
        self.workoutDraft = workoutDraft
        self.planName = planName
        self.routineName = routineName
        self.date = date
        self.intensityIndex = intensityIndex
        self.weightUnit = weightUnit
        isWorkoutRepeated = true
        for i in self.workoutDraft.indices {
            for j in self.workoutDraft[i].workoutSeriesDraftList.indices {
                self.workoutDraft[i].workoutSeriesDraftList[j].actualLoad = ""
                self.workoutDraft[i].workoutSeriesDraftList[j].actualIntensity = ""
                self.workoutDraft[i].workoutSeriesDraftList[j].actualReps = ""
            }
            self.workoutDraft[i].workoutExerciseDraft.note = ""
        }
        
        if self.workoutDraft.count > workoutHints.count {
            for _ in workoutHints.count...workoutDraft.count {
                workoutHints.append(WorkoutHints(repsHint: "reps", weightHint: weightUnit.description, intensityHint: intensityIndex.descritpion, noteHint: "note"))
            }
        }
    }
    
    func loadRoutine(isWorkoutSaved: Bool) {
        let exercisesDatabaseHelper = ExercisesDataBaseHelper()
        let plansDatabaseHelper = PlansDataBaseHelper()
        guard let planId = plansDatabaseHelper.getPlanId(planName: planName) else {
            print("planId was null in workoutView")
            return
        }
        if !isWorkoutSaved {
            initRecoveredWorkoutData()
            return
        }
        let savedRoutine = exercisesDatabaseHelper.getRoutine(routineName: routineName, planId: String(planId))
        var lastIndex: Int = 0
        for (index, savedExercise) in savedRoutine.enumerated() {
            let exercise = WorkoutExerciseDraft(exerciseType: savedExercise.exerciseType, name: savedExercise.name, pause: savedExercise.pause, pauseUnit: savedExercise.pauseUnit, series: savedExercise.series, reps: savedExercise.reps, loadUnit: savedExercise.loadUnit, intensity: savedExercise.intensity, intensityIndex: savedExercise.intensityIndex, pace: savedExercise.pace, note: "")
            if !isWorkoutRepeated {
                let seriesList: [WorkoutSeriesDraft]
                if savedExercise.intensity == nil {
                    seriesList = Array(repeating: WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: savedExercise.loadUnit, intensityIndex: savedExercise.intensityIndex, actualIntensity: nil), count: Int(savedExercise.series)!)
                } else {
                    seriesList = Array(repeating: WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: savedExercise.loadUnit, intensityIndex: savedExercise.intensityIndex, actualIntensity: ""), count: Int(savedExercise.series)!)
                }
                workoutDraft.append(WorkoutDraft(workoutExerciseDraft: exercise, workoutSeriesDraftList: seriesList))
            }
            let savedNotes = workoutHistoryDatabaseHelper.getLastTrainingNotes(planName: planName, routineName: routineName)
            if !savedNotes.isEmpty {
                if index < savedNotes.count {
                    let note = savedNotes[index]
                    if !note.isEmpty {
                        let workoutHint = WorkoutHints(repsHint: savedExercise.reps, weightHint: savedExercise.load, intensityHint: savedExercise.intensity, noteHint: note)
                        if !isWorkoutRepeated {
                            self.workoutHints.append(workoutHint)
                        } else {
                            self.workoutHints[index] = workoutHint
                        }
                    } else {
                        addDefaultHint(savedExercise: savedExercise)
                    }
                } else {
                    addDefaultHint(savedExercise: savedExercise)
                }
            } else {
                addDefaultHint(savedExercise: savedExercise)
            }
            lastIndex = index
        }
        
        if lastIndex < workoutHints.count - 1 {
            for i in lastIndex..<workoutHints.count {
                workoutHints[i] = WorkoutHints(repsHint: "reps", weightHint: weightUnit.description, intensityHint: intensityIndex.descritpion, noteHint: "note")
            }
        }
    }
    
    private func addDefaultHint(savedExercise: ExerciseDraft) {
        let workoutHint = WorkoutHints(repsHint: savedExercise.reps, weightHint: savedExercise.load, intensityHint: savedExercise.intensity, noteHint: "Note")
        self.workoutHints.append(workoutHint)
    }
    
    private func initRecoveredWorkoutData() {
        guard let recoveredWorkout = loadWorkoutFromFile() else {
            print("recovered workout was null in WorkoutView")
            return
        }
        guard let recoveredHints = loadHintsFromFile() else {
            print("recovered hints was null in WorkoutView")
            return
        }
        workoutDraft = recoveredWorkout
        workoutHints = recoveredHints
    }
    
    private func loadWorkoutFromFile() -> [WorkoutDraft]? {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let workoutURL = documentDirectory.appendingPathComponent("workout.json")
            do {
                let workoutData = try Data(contentsOf: workoutURL)
                let decoder = JSONDecoder()
                let workoutList = try decoder.decode([WorkoutDraft].self, from: workoutData)
                return workoutList.map { WorkoutDraft(workoutExerciseDraft: $0.workoutExerciseDraft, workoutSeriesDraftList:$0.workoutSeriesDraftList) }
            } catch {
                print("Error loading workout: \(error)")
            }
        }
        return nil
    }
    
    private func loadHintsFromFile() -> [WorkoutHints]? {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let hintsURL = documentDirectory.appendingPathComponent("hints.json")
            do {
                let hintsData = try Data(contentsOf: hintsURL)
                let decoder = JSONDecoder()
                let workoutHints = try decoder.decode([WorkoutHints].self, from: hintsData)
                return workoutHints.map(\.self)
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
        let workoutHints = workoutHints.map(\.self)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let workoutData = try encoder.encode(workoutList)
            let hintsData = try encoder.encode(workoutHints)
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let workoutURL = documentDirectory.appendingPathComponent("workout.json")
                let hintsURL = documentDirectory.appendingPathComponent("hints.json")
                try workoutData.write(to: workoutURL)
                try hintsData.write(to: hintsURL)
                UserDefaultsUtils.shared.setWorkoutSaved(workoutSaved: false)
                UserDefaultsUtils.shared.setUnfinishedRoutineName(routineName: routineName)
                UserDefaultsUtils.shared.setUnsavedWorkoutPlanName(planName: planName)
                UserDefaultsUtils.shared.setDate(date: date)
                print("Workout data saved at: \(workoutURL)")
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
                exerciseTpe: pair.workoutExerciseDraft.exerciseType,
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
    
    func addExercise() {
        let exerciseDraft = WorkoutExerciseDraft(name: "", pause: "0", pauseUnit: TimeUnit.min, series: "0", reps: "0", loadUnit: WeightUnit.kg, intensity: "0", intensityIndex: intensityIndex, pace: "0000", note: "", isAdded: true)
        let exerciseSetDraft = WorkoutSeriesDraft(actualReps: "", actualLoad: "", loadUnit: weightUnit, intensityIndex: intensityIndex, actualIntensity: "")
        workoutHints.append(WorkoutHints(repsHint: "Reps", weightHint: "Weight", intensityHint: intensityIndex.descritpion, noteHint: "Note"))
        workoutDraft.append(WorkoutDraft(workoutExerciseDraft: exerciseDraft, workoutSeriesDraftList: [exerciseSetDraft]))
        objectWillChange.send()
    }
    
    func removeExercise(id: UUID) {
        if let index = workoutDraft.firstIndex(where: { $0.id == id }) {
            workoutHints.remove(at: index)
            workoutDraft.remove(at: index)
        }
        objectWillChange.send()
    }
}
