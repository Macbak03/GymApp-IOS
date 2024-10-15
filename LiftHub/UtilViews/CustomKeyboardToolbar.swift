//
//  CustomKeyboardToolbar.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 15/10/2024.
//

import SwiftUI

struct CustomKeyboardToolbar: View {
    @Binding var textFieldValue: String
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: -12) {
                // Calculate button width based on the available screen width
                let buttonWidth = (geometry.size.width / 3) - 2 // Adjust width based on number of buttons
                
                // Minus Button
                Button(action: {
                    textFieldValue += "-"
                }) {
                    Text("-")
                        .frame(width: buttonWidth, height: 30)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(5)
                }
                
                // Dot Button
                Button(action: {
                    textFieldValue += "."
                }) {
                    Text(".")
                        .frame(width: buttonWidth, height: 30)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(5)
                }
                
                // Multiplication Button
                Button(action: {
                    textFieldValue += "x"
                }) {
                    Text("x")
                        .frame(width: buttonWidth, height: 30)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(5)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 50)
        .padding(.leading, -18)
    }
}


