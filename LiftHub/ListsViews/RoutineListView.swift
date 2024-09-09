//
//  RoutineListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI

struct RoutineListView: View {
    @Binding var routine: [ExerciseDraft]
    var body: some View {
        ScrollView {
            ForEach(routine.indices, id: \.self) {
                index in
                ExerciseView()
            }
        }
    }
}

struct ExerciseView: View {
    @State private var isDetailsVisible: Bool = true
    @State private var exerciseName: String = ""
    @State private var pause: String = ""
    @State private var pauseUnit: String = "" //string for now
    @State private var load: String = ""
    @State private var loadUnit: String = "" //string for now
    @State private var reps: String = ""
    @State private var series: String = ""
    @State private var intensity: String = ""
    @State private var pace: String = ""

    // Define a fixed width for all the labels to align the TextFields
    let labelWidth: CGFloat = 50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Title Section
            HStack {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isDetailsVisible ? 0 : -90))
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        withAnimation {
                            isDetailsVisible.toggle()
                        }
                    }

                TextField("Exercise name", text: $exerciseName)
                    .font(.system(size: 22, weight: .bold))
                    .frame(height: 40)
                    .padding(.leading, 10)
                    .padding(.trailing, 20)
                    .lineLimit(1)
                    .truncationMode(.tail)
//                    .overlay(ScrollView(.horizontal) {
//                        Text(exerciseName).frame(height: 40)
//                    })
                    .overlay(Rectangle() // Add underline
                        .frame(height: 1) // Thickness of underline
                        .foregroundColor(.black) // Color of underline
                        .padding(.top, 40), alignment: .bottom) // Adjust underline position

                Image(systemName: "arrow.up.arrow.down")
                    .frame(width: 50, height: 50) 
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
//            .onTapGesture {
//                withAnimation {
//                    isDetailsVisible.toggle()
//                }
//            }

            // Details Section (Toggleable)
            if isDetailsVisible {
                VStack(spacing: 14) {
                    // Pause Section
                    HStack {
                        Text("Pause")
                            .frame(width: labelWidth, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        TextField("eg. 3 or 3-5", text: $pause)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)

                        Picker("Pause", selection: $pauseUnit) {
                            Text("min").tag("min")
                            Text("s").tag("s")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 100)

                        Image(systemName: "info.circle")
                    }

                    // Load Section
                    HStack {
                        Text("Load")
                            .frame(width: labelWidth, alignment: .trailing)
                        TextField("eg. 30", text: $load)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)

                        Picker("Load", selection: $loadUnit) {
                            Text("kg").tag("kg")
                            Text("lb").tag("lb")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 100)

                        Image(systemName: "info.circle")
                    }

                    // Reps Section
                    HStack {
                        Text("Reps")
                            .frame(width: labelWidth, alignment: .trailing)
                        TextField("eg. 6 or 6-8", text: $reps)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)

                        Image(systemName: "info.circle")
                    }

                    // Series Section
                    HStack {
                        Text("Series")
                            .frame(width: labelWidth, alignment: .trailing)
                        TextField("eg. 3", text: $series)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)

                        Image(systemName: "info.circle")
                    }

                    // Intensity Section
                    HStack {
                        Text("RPE")
                            .frame(width: labelWidth, alignment: .trailing)
                        TextField("eg. 5 or 5-6", text: $intensity)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)

                        Image(systemName: "info.circle")
                    }

                    // Pace Section
                    HStack {
                        Text("Pace")
                            .frame(width: labelWidth, alignment: .trailing)
                        TextField("eg. 2110 or 21x0", text: $pace)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)

                        Image(systemName: "info.circle")
                    }
                }
                .transition(.slide)
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: isDetailsVisible)
    }
}

struct RoutineListView_Previews: PreviewProvider {
    private static let exercise1 = ExerciseDraft(name: "exercise1", pause: "3", load: "30", series: "3", reps: "8", intensity: "9", pace: "2110", wasModified: false)
    private static let exercise2 = ExerciseDraft(name: "exercise2", pause: "1", load: "10", series: "2", reps: "6", intensity: "8", pace: "21x0", wasModified: false)
    @State static var routine: [ExerciseDraft] = [exercise1, exercise2]
    static var previews: some View {
        RoutineListView(routine: $routine)
    }
}


