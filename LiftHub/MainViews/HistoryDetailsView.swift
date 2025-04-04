//
//  HistoryDetailsView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 16/09/2024.
//

import SwiftUI

struct HistoryDetailsView: View {
    @Environment(\.presentationMode) var presentationMode // Allows us to dismiss this view
    @StateObject var viewModel: HistoryDetailsViewModel
    var body: some View {
        VStack{
            HistoryDetailsListView(viewModel: viewModel)
        }
        .navigationTitle("\(viewModel.historyElement.formattedDate)  \(viewModel.historyElement.routineName)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            viewModel.loadHistoryDetails()
        }
    }
}

struct HistoryDetailsView_Previews: PreviewProvider{
    static var previews: some View {
        HistoryDetailsView(viewModel: HistoryDetailsViewModel(historyElement: WorkoutHistoryElement(planName: "", routineName: "", formattedDate: "", rawDate: "")))
    }
}
