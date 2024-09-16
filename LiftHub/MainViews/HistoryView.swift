//
//  HistoryView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 16/09/2024.
//

import SwiftUI

struct HistoryView: View {
    @State private var history = [WorkoutHistoryElement]()
    @State private var searchText = ""
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Backgroundimage(geometry: geometry, imageName: "history_icon")
                VStack {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass") // Use system icon for magnifier
                            .foregroundColor(.gray) // Set the color of the icon
                            .padding(.leading, 10)
                        
                        TextField("Search in history...", text: $searchText)
                            .padding(10) // Padding inside the text field
                            .frame(height: 50)
                        
                    }
                    .background(Color.gray.opacity(0.2)) // Background color similar to Android search view
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.top, 5)
                    
                    // Workout history list (Equivalent to RecyclerView)
                    HistoryListView(history: $history)
                }
                .onAppear() {
                    loadHistory()
                }
            }
        }
    }
    
    private func loadHistory() {
        let workoutHistoryDatabaseHelper =  WorkoutHistoryDataBaseHelper()
        history = workoutHistoryDatabaseHelper.getHistory()
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
