//
//  MessageBubbleView.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 13/11/2024.
//

import SwiftUI

struct MessageBubbleView: View {
    var text: String
    var arrowOffset: CGFloat
    
    var body: some View {
        HStack {
            // Ensure that the bubble adjusts to the text width
            Text(text)
                .padding(10) // Add padding inside the bubble for space around the text
                .background(
                    MessageBubbleShape(arrowOffset: arrowOffset)
                        .fill(Color.ShadowColor)
                )
                .foregroundColor(.TextColorSecondary) // Text color
                .font(.system(size: 14)) // Set font size as needed
                .fixedSize(horizontal: false, vertical: true) // Prevents the text from being truncated and allows it to grow
                .multilineTextAlignment(.center)
                //.padding(.bottom, 10)
        }
        .padding(.horizontal, 5) // Optional padding around the bubble
    }
}
