//
//  HistoryOptionsDialog.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 17/09/2024.
//

import SwiftUI

struct HistoryOptionsDialog: View {
    @Binding var history: [WorkoutHistoryElement]
    @Binding var noFilteredHistory: [WorkoutHistoryElement]
    private let workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    let historyItem: WorkoutHistoryElement
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var openEditHistory = false
    @State private var showAlertDialog = false
    var body: some View {
        ZStack{
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all) // Makes sure the background covers the entire screen
                .blur(radius: 50)
            VStack {
                Spacer()
                VStack{
                    // Image (SwipeButton equivalent)
                    Image(systemName: "rectangle.fill") // Substitute with your custom image
                        .resizable()
                        .frame(width: 60, height: 7)
                        .padding(.top, 5)
                        .foregroundColor(.gray) // Replace this with an appropriate background color if needed
                        .frame(maxWidth: .infinity)
                    
                    // Text Views inside a VStack
                    VStack(alignment: .center, spacing: 5) {
                        Text(historyItem.routineName)
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(Color.textColorPrimary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        
                        Text(historyItem.formattedDate)
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(Color.textColorPrimary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 15)
                    .padding(.horizontal, 10)
                    
                    // Edit Button
                    Button(action: {
                        openEditHistory = true
                    }) {
                        Text("Edit")
                            .font(.system(size: 18))
                            .foregroundColor(Color.TextColorButton)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.accentColor)
                                    .shadow(radius: 3)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    
                    // Delete Button
                    Button(action: {
                        showAlertDialog = true
                    }) {
                        Text("Delete")
                            .font(.system(size: 18))
                            .foregroundColor(Color.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.ShadowColor)
                                    .shadow(radius: 3)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 5)
                    .alert(isPresented: $showAlertDialog) {
                        Alert(
                            title: Text("Warning"),
                            message: Text("Are you sure you want to delete \(historyItem.routineName) from \(historyItem.formattedDate)?"),
                            primaryButton: .destructive(Text("OK")) {
                                deleteHistory()
                                presentationMode.wrappedValue.dismiss()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    // Cancel Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 18))
                            .foregroundColor(Color.TextColorButton)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.accentColor)
                                    .shadow(radius: 3)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 15)
                    .padding(.bottom, 50)
                    
                }
                .background(Color.BackgroundColor)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)
                .frame(maxWidth: .infinity) // Take the full width at the bottom
            }
            .fullScreenCover(isPresented: $openEditHistory) {
                EditHistoryDetailsView(workoutHistoryElement: historyItem, showWorkoutSavedToast: $showToast, savedWorkoutToastMessage: $toastMessage)
            }
            .onChange(of: showToast) { _, exit in
                if exit {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    func deleteHistory() {
        workoutHistoryDatabaseHelper.deleteFromHistory(date: historyItem.rawDate)
        history.removeAll(where: { $0.rawDate == historyItem.rawDate && $0.planName == historyItem.planName && $0.routineName == historyItem.routineName})
        noFilteredHistory.removeAll(where: { $0.rawDate == historyItem.rawDate && $0.planName == historyItem.planName && $0.routineName == historyItem.routineName})
    }
}

struct HistoryOptionsDialog_Previews: PreviewProvider {
    @State static var history: [WorkoutHistoryElement] = [WorkoutHistoryElement(planName: "Plan", routineName: "Routine", formattedDate: "17.09.2024", rawDate: "17.09.2024 22:52:12")]
    static var workoutHistoryDatabaseHelper = WorkoutHistoryDataBaseHelper()
    @State static var showToast = true
    @State static var toastMessage: String = ""
    static var previews: some View {
        HistoryOptionsDialog(history: $history, noFilteredHistory: $history, historyItem: WorkoutHistoryElement(planName: "Plan", routineName: "Routine", formattedDate: "17.09.2024", rawDate: "17.09.2024 22:52:12"), showToast: $showToast, toastMessage: $toastMessage)
    }
}

