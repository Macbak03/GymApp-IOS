//
//  ToastView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 10/09/2024.
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20)
    }
}


struct ToastView_Previews: PreviewProvider{
    static var previews: some View{
        ToastView(message: "This is toast message")
    }
}
