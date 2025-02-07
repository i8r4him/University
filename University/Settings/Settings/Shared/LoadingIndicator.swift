//
//  LoadingIndicator.swift
//  Notiva
//
//  Created by Ibrahim Abdullah
//

import SwiftUI

struct LoadingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.accentColor, lineWidth: 2)
            .frame(width: 20, height: 20)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview {
    LoadingIndicator()
}
