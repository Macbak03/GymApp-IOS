//
//  PlanViewModel.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 21/11/2024.
//

import Foundation

class PlanViewModel: ObservableObject {
    @Published var planName: String? = nil
    var position: Int?
    
    init(planName: String? = nil, position: Int? = nil) {
        self.planName = planName
        self.position = position
    }
    
    func initViewModel(planName: String, position: Int) {
        self.planName = planName
        self.position = position
    }
    
}
