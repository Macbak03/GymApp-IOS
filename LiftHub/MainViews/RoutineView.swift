//
//  RoutineView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI
import Foundation

struct RoutineView: View {
    @State private var routine: [ExerciseDraft] = []
    @State var routineName: String = ""
    let planName: String
    @State private var showAlertDialog = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    // HStack for Back Button at the top-left corner
                    HStack {
                        ZStack {
                            // HStack to position the back button on the left
                            HStack {
                                Button(action: {
                                    // Dismiss the current view to go back
                                    showAlertDialog = true
                                }) {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 20, weight: .bold))
                                }
                                .padding(.leading, 30) // Padding to keep the button away from the edge
                                .alert(isPresented: $showAlertDialog) {
                                    Alert(
                                        title: Text("Warning"),
                                        message: Text("Routine or it's changes won't be saved. Do you want to cancel?"),
                                        primaryButton: .destructive(Text("Yes")) {
                                            presentationMode.wrappedValue.dismiss()
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                                
                                Spacer() // Pushes the button to the left
                            }
                            
                            // Centered TextField
                            HStack {
                                Spacer() // Push the TextField to the center
                                
                                TextField("Enter training plan name", text: $routineName)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .frame(maxWidth: 250)
                                    .multilineTextAlignment(.center)
                                
                                Spacer() // Push the TextField to the center
                            }
                        }
                    }
                    
                    RoutineListView(routine: $routine)
                    
                    Spacer()
                    ZStack{
                        HStack{
                            AddButton(routine: $routine, geometry: geometry)
                        }
                        HStack{
                            Button(action: {
                                //save routine
                            }) {
                                Text("Save")
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
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

private struct AddButton: View {
    @Binding var routine: [ExerciseDraft]
    let geometry: GeometryProxy
    var buttonScale = 0.135
    var buttonOffsetX = 0.4
    var buttonOffsetY = 0.1
    private let newExercise = ExerciseDraft(name: "", pause: "", load: "", series: "", reps: "", intensity: "", pace: "", wasModified: false)
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
    static var previews: some View {
        GeometryReader { geometry in
            RoutineView(routineName: "", planName: "Plan")
        }
    }
}
