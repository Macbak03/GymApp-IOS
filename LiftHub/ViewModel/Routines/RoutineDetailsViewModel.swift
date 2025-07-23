//
//  RoutineDetailsViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 21/11/2024.
//

import Foundation

class RoutineDetailsViewModel: ObservableObject {
    @Published var routineDraft: [ExerciseDraft] = []
    @Published var routineName: String = ""
    @Published var wasExerciseModified = false
    
    @Published var showToast = false
    @Published var toastMessage = ""
    
    @Published var descriptionType: DescriptionType? = nil
    @Published var alertType: AlertType? = nil
    @Published var wasRoutineLoaded = false
    
    @Published var wasSuccesfullySaved = false
    
    private let exercisesDatabaseHelper = ExercisesDataBaseHelper()
    private let routinesDatabaseHelper = RoutinesDataBaseHelper()
    
    var planName: String = ""
    
    init(routineDraft: [ExerciseDraft] = [], routineName: String = "") {
        self.routineDraft = routineDraft
        self.routineName = routineName
    }
    
    func setPlanName(planName: String){
        self.planName = planName
    }
    
    func addExercise() {
        let newExercise = ExerciseDraft(name: "", pause: "", pauseUnit: TimeUnit.min, load: "", loadUnit: WeightUnit(rawValue: UserDefaultsUtils.shared.getWeightUnit()) ?? .kg, series: "", reps: "", intensity: "", intensityIndex: IntensityIndex(rawValue: UserDefaultsUtils.shared.getIntensity()) ?? .RPE, pace: "", wasModified: false)
        routineDraft.append(newExercise)
    }
    
    func loadRoutine(originalRoutineName: String?, planId: Int64) {
        guard let checkedOriginalRoutineName = originalRoutineName else {
            return
        }
        routineName = checkedOriginalRoutineName
        routineDraft = exercisesDatabaseHelper.getRoutine(routineName: checkedOriginalRoutineName, planId: String(planId))
    }
    
    private func getRoutine() throws -> [Exercise] {
        var routine = [Exercise]()
        var routineNames = [String]()
        
        for exerciseDraft in routineDraft {
            let exercise = try exerciseDraft.toExercise()
            
            if routineNames.contains(exercise.name) {
                throw ValidationException(message: "You can't create routine with exercises with the same name.")
            } else {
                routineNames.append(exercise.name)
                routine.append(exercise)
            }
        }
        return routine
    }
    
    
    func saveRoutineIntoDB(routinesViewModel: RoutinesViewModel, originalRoutineName: String?) throws {
        let routinesDatabaseHelper = RoutinesDataBaseHelper()
        // Check if routine draft is empty
        if routineDraft.isEmpty {
            throw ValidationException(message: "You must add at least one exercise to the routine.")
        }
        // Check if routine name is empty
        if routineName.isEmpty {
            throw ValidationException(message: "Routine name cannot be empty.")
        }
        //Check if routine with given name already exists
        if routinesDatabaseHelper.doesRoutineExist(routineName: routineName, planId: routinesViewModel.planId, originalRoutineName: originalRoutineName) {
            throw ValidationException(message: "Routine with given name already exists.")
        }
        // Try to get the routine and handle possible exceptions
        do {
            let routine = try getRoutine()
            
            exercisesDatabaseHelper.addRoutine(routine: routine, routineName: routineName, planId: routinesViewModel.planId, originalRoutineName: originalRoutineName)
            
            routinesViewModel.showToast = true
            routinesViewModel.refreshRoutines = true
            routinesViewModel.toastMessage = "Routine \(routineName) saved."
            wasSuccesfullySaved = true
        } catch let error as ValidationException {
            // Handle validation errors
            showToast = true
            toastMessage = error.message
        }
    }
    
    func deleteItem(atOffsets: IndexSet) {
        routineDraft.remove(atOffsets: atOffsets)
        wasExerciseModified = true
    }
    
    func moveItem(from source: IndexSet, to destination: Int) {
        routineDraft.move(fromOffsets: source, toOffset: destination)
    }
    
    func setToast(message: String) {
        toastMessage = message
        showToast = true
    }
    
}

enum AlertType: Identifiable {
    case navigation
    case description(DescriptionType)
    
    var id: Int {
        switch self {
        case .navigation:
            return 0
        case .description(let type):
            return type.rawValue
        }
    }
}

enum DescriptionType: Int, Identifiable {
    case pause = 1
    case load = 2
    case reps = 3
    case series = 4
    case intensity = 5
    case pace = 6
    
    var id: Self {self}
}
