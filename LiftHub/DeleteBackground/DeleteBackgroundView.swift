//
//  DeleteBackgroundView.swift
//  LiftHub
//
//  Created by Maciej "wielki" Bąk on 12/09/2024.
//

import SwiftUI

struct DeleteBackgroundView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Color.red
                .cornerRadius(5)
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "xmark.bin.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 20)
                    .foregroundColor(.white)
                Text("Delete")
                    .foregroundStyle(.white)
                    .font(.system(size: 20, weight: .bold))
            }
        }
    }
}

struct DeleteBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
       DeleteBackgroundView()
    }
}
