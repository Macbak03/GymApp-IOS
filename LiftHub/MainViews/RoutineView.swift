//
//  RoutineView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI
import Foundation

struct RoutineView: View {
    @State private var routineDraft: [ExerciseDraft] = []
    @State var routineName: String = ""
    let originalRoutineName: String?
    let planName: String
    let planId: Int64
    private let exercisesDatabaseHelper = ExercisesDataBaseHelper()
    
    @State private var showAlertDialog = false
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @Binding var refreshRoutines: Bool
    @Binding var successfullySaved: Bool
    @Binding var savedMessage: String
    
    @State private var descriptionType: DescriptionType? = nil
    @State private var alertType: AlertType? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    // Centered TextField
                    HStack {
                        Spacer() // Push the TextField to the center
                        
                        TextField("Enter routine name", text: $routineName)
                            .font(.system(size: 18))
                            .frame(height: 40)
                            .background(Color.ShadowColor)
                            .cornerRadius(10)
                            .padding(.horizontal, 50)
                        
                            .multilineTextAlignment(.center)
                        
                        Spacer() // Push the TextField to the center
                    }
                    
                    RoutineListView(routine: $routineDraft, showToast: $showToast, toastMessage: $toastMessage, descriptionType: $descriptionType, alertType: $alertType)
                        .onAppear() {
                            loadRoutine()
                        }
                    
                    Spacer()
                    
                    Button(action: {
                        do {
                            try saveRoutineIntoDB()
                        } catch let error as ValidationException {
                            showToast = true
                            toastMessage = error.message
                        } catch {
                            showToast = true
                            toastMessage = "Unexpected error occured: \(error)"
                        }
                        
                    }) {
                        Text("Save")
                            .foregroundColor(Color.TextColorButton)
                            .font(.system(size: 18))
                            .foregroundColor(Color.white)
                            .padding()
                            .frame(maxWidth: 125, maxHeight: 45)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.accentColor)
                                    .shadow(radius: 3)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 50)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .alert(item: $alertType) { alertType in
            switch alertType {
            case .navigation:
                return Alert(
                    title: Text("Warning"),
                    message: Text("Routine's changes won't be saved. Do you want to cancel?"),
                    primaryButton: .destructive(Text("Yes")) {
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            case .description(let descriptionType):
                switch descriptionType {
                case .pause:
                    return showDescriptionDialog(title: "Rest", message: "A period of time between sets, allowing the muscles to recover partially before the next set.")
                case .load:
                    return showDescriptionDialog(title: "Load", message: "The amount of weight lifted during an exercise, measured in kilograms or pounds. Value typed here is for reference during the workout.")
                case .reps:
                    return showDescriptionDialog(title: "Reps", message: "Short for repetitions, reps refer to the number of times a particular exercise is performed in a set. For example 10 reps of bench press means you can perform bench press for 10 reps in 1 set.")
                case .series:
                    return showDescriptionDialog(title: "Series", message: "Also known as sets, a series refers to a group of consecutive repetitions of an exercise. For example 3 sets of bench press means you can perform bench press for similar number of times 3 times in a row with a rest between.")
                case .intensity:
                    return showDescriptionDialog(title: "Intensity", message: "It's a subjective measure used to gauge the intensity of exercise based on how difficult it feels. RPE typically ranges from 1 to 10, with 1 being very easy and 10 being maximal exertion.RIR is almost the same as RPE, but 0 means maximal exertion and 10 - very easy.")
                case .pace:
                    return showDescriptionDialog(title: "Pace", message: "First number is eccentric phase - muscle stretching phase. \n\nSecond number is pause after eccentric phase. \n\nThird number is concentric phase - the muscle shortens as it contracts. \n\nThe fourth number is pause after concentric phase. \n\nEverything is measured in seconds, \"x\" means as fast as you can \nFor example pace 21x0 in bench press means you go down for 2 seconds, 1 second pause at the bottom, push as fast as you can to the top and immediately start to go down again.")
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    alertType = .navigation
                }) {
                    HStack {
                        Image (systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    addExercise()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .toast(isShowing: $showToast, message: toastMessage)
    }
    
    private func addExercise() {
        let newExercise = ExerciseDraft(name: "", pause: "", pauseUnit: TimeUnit.min, load: "", loadUnit: WeightUnit(rawValue: UserDefaultsUtils.shared.getWeight()) ?? .kg, series: "", reps: "", intensity: "", intensityIndex: IntensityIndex(rawValue: UserDefaultsUtils.shared.getIntensity()) ?? .RPE, pace: "", wasModified: false)
        routineDraft.append(newExercise)
    }
    
    private func showDescriptionDialog(title: String, message: String) -> Alert {
        return Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .destructive(Text("OK")),
            secondaryButton: .cancel()
        )
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
    
    private func loadRoutine() {
        guard let checkedOriginalRoutineName = originalRoutineName else {
            return
        }
        routineName = checkedOriginalRoutineName
        routineDraft = exercisesDatabaseHelper.getRoutine(routineName: checkedOriginalRoutineName, planId: String(planId))
    }
    
    
    private func saveRoutineIntoDB() throws {
        // Check if routine draft is empty
        if routineDraft.isEmpty {
            throw ValidationException(message: "You must add at least one exercise to the routine.")
        }
        // Check if routine name is empty
        if routineName.isEmpty {
            throw ValidationException(message: "Routine name cannot be empty.")
        }
        // Try to get the routine and handle possible exceptions
        do {
            let routine = try getRoutine()
            exercisesDatabaseHelper.addRoutine(routine: routine, routineName: routineName, planId: planId, originalRoutineName: originalRoutineName)
            
            successfullySaved = true
            refreshRoutines = true
            savedMessage = "Routine \(routineName) saved."
            presentationMode.wrappedValue.dismiss()
        } catch let error as ValidationException {
            // Handle validation errors
            showToast = true
            toastMessage = error.message
        }
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

private struct AddButton: View {
    @Binding var routine: [ExerciseDraft]
    let geometry: GeometryProxy
    var buttonScale = 0.135
    var buttonOffsetX = 0.4
    var buttonOffsetY = 0.1
    
    private let newExercise = ExerciseDraft(name: "", pause: "", pauseUnit: TimeUnit.min, load: "", loadUnit: WeightUnit(rawValue: UserDefaultsUtils.shared.getWeight()) ?? .kg, series: "", reps: "", intensity: "", intensityIndex: IntensityIndex(rawValue: UserDefaultsUtils.shared.getIntensity()) ?? .RPE, pace: "", wasModified: false)
    var body: some View {
        Button(action: {
            routine.append(newExercise)
        }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: geometry.size.width * buttonScale, height: geometry.size.width * buttonScale)
        }
        .position(x: geometry.size.width * buttonOffsetX, y: geometry.size.height * buttonOffsetY)
        .frame(
            width: geometry.size.width * buttonScale,
            height: geometry.size.height * buttonScale
        )
    }
}

struct RoutineView_Previews: PreviewProvider {
    @State static var successfullySaved = false
    @State static var refreshRoutines = false
    @State static var savedMessage = ""
    static var previews: some View {
        GeometryReader { geometry in
            RoutineView(routineName: "", originalRoutineName: nil, planName: "Plan", planId: 0, refreshRoutines: $refreshRoutines, successfullySaved: $successfullySaved, savedMessage: $savedMessage)
        }
    }
}
