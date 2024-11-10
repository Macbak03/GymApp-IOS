//
//  MessageBubbleShape.swift
//  Lift-Hub
//
//  Created by Maciej "wielki" Bąk on 10/11/2024.
//

import SwiftUI

struct MessageBubbleShape: Shape {
    var arrowOffset: CGFloat // The offset to determine how far left or right the arrow should point
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Draw the rounded rectangle for the main part of the bubble
        let cornerRadius: CGFloat = 30
        let arrowHeight: CGFloat = 20
        let bubbleHeight = rect.height - arrowHeight

        path.addRoundedRect(
            in: CGRect(x: 0, y: 0, width: rect.width, height: bubbleHeight),
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )

        // Calculate the start point of the arrow
        let bubbleMidX = rect.midX
        let arrowTipX = bubbleMidX + arrowOffset

        // Draw the arrow starting from the center of the bubble and pointing downwards
        let pointerWidth: CGFloat = 15 // Width of the base of the arrow
        path.move(to: CGPoint(x: bubbleMidX - pointerWidth / 2, y: bubbleHeight)) // Start of arrow base left
        path.addLine(to: CGPoint(x: arrowTipX, y: rect.height)) // Arrow tip pointing downwards
        path.addLine(to: CGPoint(x: bubbleMidX + pointerWidth / 2, y: bubbleHeight)) // End of arrow base right

        path.closeSubpath()

        return path
    }
}



