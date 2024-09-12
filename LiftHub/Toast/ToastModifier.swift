//
//  ToastModifier.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import SwiftUI

enum ToastDuration {
    case short, medium, long
    
    var timeInterval: TimeInterval {
            switch self {
            case .short:
                return 2.0
            case .medium:
                return 3.0
            case .long:
                return 4.0
            }
        }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let duration: ToastDuration

    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Spacer()
                    ToastView(message: message)
                        .transition(AnyTransition.opacity.animation(.easeInOut))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration.timeInterval) {
                                isShowing = false
                            }
                        }
                    Spacer().frame(height: 50) // Offset from the bottom
                }
                .zIndex(1)
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String, duration: ToastDuration = ToastDuration.medium) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message, duration: duration))
    }
}

