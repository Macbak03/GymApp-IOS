//
//  HistoryListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 16/09/2024.
//

import SwiftUI

struct HistoryListView: View {
    @Binding var history: [WorkoutHistoryElement]
    @Binding var noFilteredHistory: [WorkoutHistoryElement]
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    var body: some View {
        List {
            ForEach(Array(history.enumerated()), id: \.element) {
                (index, element) in
                NavigationLink(
                    destination: HistoryDetailsView(
                        rawDate: element.rawDate,
                        date: element.formattedDate,
                        planName: element.planName,
                        routineName: element.routineName),
                    label: {
                        HistoryListElementView(history: $history, noFilteredHistory: $noFilteredHistory, historyItem: element, position: index, showToast: $showToast, toastMessage: $toastMessage)
                    }
                )
                
                
            }
        }
    }
}

struct HistoryListElementView: View {
    @Binding var history: [WorkoutHistoryElement]
    @Binding var noFilteredHistory: [WorkoutHistoryElement]
    let historyItem: WorkoutHistoryElement
    let position: Int
    @State private var showOptionsDialog = false
    @State private var openHistoryDetails = false
    
    @Binding var showToast: Bool
    @Binding var toastMessage: String

    var body: some View {
        VStack {
            ZStack(alignment: .trailing) {
                VStack {
                    Text(historyItem.planName)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 1)
                        .allowsHitTesting(false)
                    
                    HStack {
                        Text(historyItem.formattedDate)
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: 100, alignment: .leading)
                            .padding(.leading, 10)
                            .allowsHitTesting(false)

                        
                        Text(historyItem.routineName)
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 10)
                            .allowsHitTesting(false)

                    }
//                    .padding(.bottom, 5)
//                    .padding(.horizontal, 25)
                }
                Button(action: {
                    showOptionsDialog = true
                }) {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .frame(width: 15, height: 3)
                        .padding()
                        .rotationEffect(.degrees(90))
                }
                .frame(width: 30, height: 20, alignment: .trailing)
                .background(Color.clear) // You can modify this to fit the background style
            }
        }
//        .background(Color.BackgroundColorList)
//        .cornerRadius(8)
//        .shadow(radius: 3)
//        .padding(.horizontal, 10)
//        .frame(maxWidth: .infinity)
        .onTapGesture {
            showOptionsDialog = true
        }
        .fullScreenCover(isPresented: $openHistoryDetails){
            HistoryDetailsView(rawDate: historyItem.rawDate, date: historyItem.formattedDate, planName: historyItem.planName, routineName: history[position].routineName)
        }
        .sheet(isPresented: $showOptionsDialog) {
            HistoryOptionsDialog(history: $history, noFilteredHistory: $noFilteredHistory, historyItem: historyItem, showToast: $showToast, toastMessage: $toastMessage)
        }
    }
}

struct HistoryListView_Previews: PreviewProvider {
    static let workout = WorkoutHistoryElement(planName: "Plan", routineName: "Routine", formattedDate: "16.09.2024", rawDate: "16.09.2024 21:22:45")
    static let workout1 = WorkoutHistoryElement(planName: "Plan1", routineName: "Routine1", formattedDate: "17.09.2024", rawDate: "17.09.2024 16:22:45")
    @State static var history = [workout, workout1]
    @State static var showToast = false
    @State static var toastMessage = ""
    static var previews: some View {
        HistoryListView(history: $history, noFilteredHistory: $history, showToast: $showToast, toastMessage: $toastMessage)
    }
}
