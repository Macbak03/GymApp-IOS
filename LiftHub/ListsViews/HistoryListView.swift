//
//  HistoryListView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 16/09/2024.
//

import SwiftUI

struct HistoryListView: View {
    @ObservedObject var viewModel: HistoryViewModel
    var body: some View {
        List {
            ForEach(Array(viewModel.filteredHistory.enumerated()), id: \.element) {
                (index, element) in
                NavigationLink(
                    destination: HistoryDetailsView(viewModel: HistoryDetailsViewModel(historyElement: element)),
                    label: {
                        HistoryListElementView(historyViewModel: viewModel, viewModel: HistoryElementViewModel(historyElement: element, position: index, showToast: viewModel.showToast, toastMessage: viewModel.toastMessage))
                    }
                )
                
                
            }
        }
    }
}

struct HistoryListElementView: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    @StateObject var viewModel: HistoryElementViewModel
    
    @State private var showOptionsDialog = false
    @State private var openHistoryDetails = false
    @State private var openEditHistory = false
    @State private var showAlertDialog = false
    
    

    var body: some View {
        VStack {
            ZStack(alignment: .trailing) {
                VStack {
                    Text(viewModel.historyElement.planName)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 1)
                        .allowsHitTesting(false)
                    
                    HStack {
                        Text(viewModel.historyElement.formattedDate)
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: 100, alignment: .leading)
                            .padding(.leading, 10)
                            .allowsHitTesting(false)

                        
                        Text(viewModel.historyElement.routineName)
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 10)
                            .allowsHitTesting(false)

                    }

                }
                Menu {
                    NavigationLink ( 
                        destination: EditHistoryDetailsView(historyElementViewModel: viewModel)
                            .onDisappear() {
                                historyViewModel.showToast = viewModel.showToast
                                historyViewModel.toastMessage = viewModel.toastMessage
                            },
                        label: {
                            Button(action: {
                                openEditHistory = true
                            }) {
                                HStack {
                                    Text("Edit")
                                        .foregroundColor(Color.accentColor)
                                    Image(systemName: "square.and.pencil")
                                        .padding()
                                        .foregroundColor(Color.accentColor)
                                }
                            }
                        }
                    )
                    
                    Button(role: .destructive, action: {
                        showAlertDialog = true
                    }) {
                        HStack {
                            Text("Delete")
                                .foregroundColor(Color.red)
                            Image(systemName: "trash")
                                .padding()
                                .foregroundColor(Color.red)
                        }
                        .foregroundStyle(Color.red)
                    }
                    
                } label: {
                    Button(action: {
                    }) {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .frame(width: 15, height: 3)
                            .padding()
                            .rotationEffect(.degrees(90))
                    }
                    .frame(width: 30, height: 20)
                    .background(Color.clear)
                }
            }
        }
        .onTapGesture {
            showOptionsDialog = true
        }
        .alert(isPresented: $showAlertDialog) {
            Alert(
                title: Text("Warning"),
                message: Text("Are you sure you want to delete \(viewModel.historyElement.routineName) from \(viewModel.historyElement.formattedDate)?"),
                primaryButton: .destructive(Text("OK")) {
                    historyViewModel.deleteFromHistory(historyItem: viewModel.historyElement)
                },
                secondaryButton: .cancel()
            )
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
        HistoryListView(viewModel: HistoryViewModel())
    }
}
