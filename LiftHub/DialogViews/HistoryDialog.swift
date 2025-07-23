//
//  HistoryDialog.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 10/12/2024.
//

import SwiftUI

struct HistoryDialog: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var historyElements: WorkoutHistoryElements
    @Binding var dateSelected: DateComponents?
    @State private var indexSet: IndexSet = []
    @State private var showAlertDialog = false
    @State private var indexToDelete = -1
    
    var body: some View {
        NavigationStack {
            Group {
                if dateSelected != nil {
                    List {
                        ForEach(foundTrainings.indices, id: \.self) { index in
                            TrainingDayListView(viewModel: HistoryElementViewModel(historyElement: foundTrainings[index], position: index))
                                .id(foundTrainings.count)
                        }
                        .onDelete(perform: { indexSet in
                            self.indexSet = indexSet
                            indexSet.forEach { index in
                                indexToDelete = index
                            }
                            showAlertDialog = true
                        })
                    }
                }
            }
            .navigationTitle(dateSelected?.date?.formatted(date: .long, time: .omitted) ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlertDialog) {
                Alert(
                    title: Text("Warning"),
                    message: Text("Are you sure you want to delete \(foundTrainings[indexToDelete].routineName) from \(foundTrainings[indexToDelete].formattedDate)?"),
                    primaryButton: .destructive(Text("Yes")) {
                        historyElements.deleteFromHistory(atOffsets: indexSet)
                    },
                    secondaryButton: .cancel()
                )
            }
            .onChange(of: foundTrainings.count) {
                if foundTrainings.count < 1 {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private var foundTrainings: [WorkoutHistoryElement] {
        if let dateSelected {
            return historyElements.history
                .filter { CustomDate.rawStringToDate($0.rawDate)?.startOfDay == dateSelected.date!.startOfDay }
        }
        return []
    }
}

struct TrainingDayListView: View {
    @StateObject var viewModel: HistoryElementViewModel
    
    
    var body: some View {
        NavigationLink (
            destination: EditHistoryDetailsView(historyElementViewModel: viewModel),
            label: {
                VStack {
                    Text(viewModel.historyElement.planName)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .allowsHitTesting(false)
                    
                    
                    
                    Text(viewModel.historyElement.routineName)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .allowsHitTesting(false)
                    
                    
                }
            }
        )
    }
}
