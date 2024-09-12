//
//  BackgroundImage.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 12/09/2024.
//

import SwiftUI

struct Backgroundimage: View {
    let geometry: GeometryProxy
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .frame(width: 250, height: 250)
            .opacity(0.2)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
    }
}
