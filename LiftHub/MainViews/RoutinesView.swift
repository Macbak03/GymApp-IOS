//
//  Routines.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 09/09/2024.
//

import SwiftUI
import Foundation

struct RoutinesView: View {
    let planName: String
    @StateObject var viewModel = RoutinesViewModel()
    @Environment(\.presentationMode) var presentationMode // Allows us to dismiss this view
    
    var body: some View {
        
        
        GeometryReader { geometry in
            ZStack {
                VStack {
                    RoutinesListView(viewModel: viewModel)
                        .onChange(of: viewModel.refreshRoutines) { _, refreshNeeded in
                            if refreshNeeded {
                                viewModel.loadRoutines()
                                viewModel.refreshRoutines = false
                            }
                            
                        }
                        .onAppear() {
                            viewModel.initPlanName(planName: planName)
                            viewModel.loadRoutines()
                        }
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .navigationTitle(planName)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(
                        destination: RoutineView(originalRoutineName: nil, routinesViewModel: viewModel),
                        label: {
                            Image(systemName: "plus")
                        }
                    )
                }
            }
            .toast(isShowing: $viewModel.showToast, message: viewModel.toastMessage)
            .onAppear() {
                
            }
        }
    }
}


private struct AddButton: View {
    @Binding var openRoutine: Bool
    let geometry: GeometryProxy
    var buttonScale = 0.14
    var buttonOffsetX = 0.35
    var buttonOffsetY = 0.1
    let planName: String
    var body: some View {
        Button(action: {
            openRoutine = true
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

struct RoutinesView_Previews: PreviewProvider {
    static var plansDatabaseHelper = PlansDataBaseHelper()
    static var previews: some View {
        RoutinesView(planName: "", viewModel: RoutinesViewModel())
    }
}
