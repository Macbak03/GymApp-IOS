//
//  HistoryListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 16/09/2024.
//

import SwiftUI

struct HistoryListView: View {
    @Binding var history: [WorkoutHistoryElement]
    var body: some View {
        ScrollView {
            ForEach(history.indices, id: \.self) {
                index in
                HistoryListElementView(historyElement: $history[index])
                
            }
            .padding(.top, 5)
        }
    }
}

struct HistoryListElementView: View {
    @Binding var historyElement: WorkoutHistoryElement
    @State private var showOptionsDialog = false
    @State private var openHistoryDetails = false
    var body: some View {
        VStack {
            ZStack(alignment: .trailing) {
                VStack {
                    Text(historyElement.planName)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 1)
                    
                    HStack {
                        Text(historyElement.formattedDate)
                            .font(.system(size: 23, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.leading, 10)
                        
                        Text(historyElement.routineName)
                            .font(.system(size: 23))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 10)
                    }
                    .padding(.bottom, 5)
                    .padding(.horizontal, 25)
                }
                Button(action: {
                    showOptionsDialog = true
                }) {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .frame(width: 20, height: 5)
                        .padding()
                        .rotationEffect(.degrees(90))
                }
                .frame(width: 30, height: 50, alignment: .trailing)
                .background(Color.clear) // You can modify this to fit the background style
            }
        }
        .background(Color.BackgroundColorList)
        .cornerRadius(8)
        .shadow(radius: 3)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            openHistoryDetails = true
        }
        .fullScreenCover(isPresented: $openHistoryDetails){
            HistoryDetailsView(rawDate: historyElement.rawDate, date: historyElement.formattedDate, planName: historyElement.planName, routineName: historyElement.routineName)
        }
    }
}

struct HistoryListView_Previews: PreviewProvider {
    static let workout = WorkoutHistoryElement(planName: "Plan", routineName: "Routine", formattedDate: "16.09.2024", rawDate: "16.09.2024 21:22:45")
    static let workout1 = WorkoutHistoryElement(planName: "Plan1", routineName: "Routine1", formattedDate: "17.09.2024", rawDate: "17.09.2024 16:22:45")
    @State static var history = [workout, workout1]
    static var previews: some View {
        HistoryListView(history: $history)
    }
}
