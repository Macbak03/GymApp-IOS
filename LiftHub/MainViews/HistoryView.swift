//
//  HistoryView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 16/09/2024.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var searchText = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                //Backgroundimage(geometry: geometry, imageName: "history_icon")
                VStack {
                     //Search bar
                    HStack {
                        Image(systemName: "magnifyingglass") // Use system icon for magnifier
                            .foregroundColor(.gray) // Set the color of the icon
                            .padding(.leading, 10)

                        TextField("Search in history...", text: $searchText)
                            .padding(10) // Padding inside the text field
                            .frame(height: 35)
                            .onChange(of: searchText) { _, newText in
                                filterSearchResults()
                            }
                        
                    }
                    
                    .background(Color.ShadowColor) // Background color similar to Android search view
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    
                    // Workout history list (Equivalent to RecyclerView)
                    HistoryListView(viewModel: viewModel)
                }
                .searchable(text: $searchText)

            }
            .onAppear() {
                viewModel.loadHistory()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .toast(isShowing: $viewModel.showToast, message: viewModel.toastMessage)
        }
    }
    
    
    private func filterSearchResults() {
        if searchText.isEmpty {
            viewModel.filteredHistory = viewModel.history
        } else {
            let lowercasedQuery = searchText.lowercased()
            viewModel.filteredHistory = viewModel.history.filter { historyItem in
                let planNameMatch = historyItem.planName.lowercased().starts(with: lowercasedQuery)
                let routineNameMatch = historyItem.routineName.lowercased().starts(with: lowercasedQuery)
                let dateMatch = historyItem.formattedDate.lowercased().contains(lowercasedQuery)
                
//                print("Query: \(lowercasedQuery), Plan: \(historyItem.planName), Routine: \(historyItem.routineName), Date: \(historyItem.formattedDate)")
//                print("Matches - Plan: \(planNameMatch), Routine: \(routineNameMatch), Date: \(dateMatch)")
//                print("List elements:\n")
//                for result in searchList {
//                    print("\(result.formattedDate) \(result.planName) \(result.routineName)\n")
//                }
                
                return planNameMatch || routineNameMatch || dateMatch
            }
            //print("------------------------------------")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
