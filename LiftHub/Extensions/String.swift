//
//  String.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 17/07/2025.
//

extension String {
    var dotFormatted: String {
        self.replacingOccurrences(of: ",", with: ".")
    }
}
