//
//  RoutineView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI
import Foundation

struct RoutineView: View {
    let originalRoutineName: String?
    @ObservedObject var routinesViewModel: RoutinesViewModel
    @StateObject var viewModel = RoutineDetailsViewModel()
        
    @State private var showAlertDialog = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    // Centered TextField
                    HStack {
                        Spacer() // Push the TextField to the center
                        
                        TextField("Enter routine name", text: $viewModel.routineName)
                            .font(.system(size: 18))
                            .frame(height: 40)
                            .background(Color.ShadowColor)
                            .cornerRadius(10)
                            .padding(.horizontal, 50)
                            .multilineTextAlignment(.center)
                            .onChange(of: viewModel.routineName) { _, _ in
                                if viewModel.wasRoutineLoaded {
                                    viewModel.wasExerciseModified = true
                                }
                            }
                        
                        
                        Spacer() // Push the TextField to the center
                    }
                    
                    RoutineListView(viewModel: viewModel)
                        
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .alert(item: $viewModel.alertType) { alertType in
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
        .navigationTitle((originalRoutineName != nil) ? "Edit Routine" : "Create Routine")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    if viewModel.wasExerciseModified {
                        viewModel.alertType = .navigation
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Image (systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button(action: {
                        viewModel.addExercise()
                        viewModel.wasExerciseModified = true
                    }) {
                        Image(systemName: "plus")
                    }
                    
                    Button(action: {
                        do {
                            try viewModel.saveRoutineIntoDB(routinesViewModel: routinesViewModel, originalRoutineName: originalRoutineName)
                            if viewModel.wasSuccesfullySaved {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } catch let error as ValidationException {
                            viewModel.showToast = true
                            viewModel.toastMessage = error.message
                        } catch {
                            viewModel.showToast = true
                            viewModel.toastMessage = "Unexpected error occured: \(error)"
                        }
                    }) {
                        Text("Save")
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadRoutine(originalRoutineName: originalRoutineName, planId: routinesViewModel.planId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.wasRoutineLoaded = true
            }
            if viewModel.routineDraft.isEmpty {
                viewModel.addExercise()
            }
        }
        .toast(isShowing: $viewModel.showToast, message: viewModel.toastMessage)
    }
    
    
    
    
    private func showDescriptionDialog(title: String, message: String) -> Alert {
        return Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .destructive(Text("OK")),
            secondaryButton: .cancel()
        )
    }
    
    
}

struct RoutineView_Previews: PreviewProvider {
    @State static var successfullySaved = false
    @State static var refreshRoutines = false
    @State static var savedMessage = ""
    static var previews: some View {
        GeometryReader { geometry in
            RoutineView(originalRoutineName: nil, routinesViewModel: RoutinesViewModel())
        }
    }
}
