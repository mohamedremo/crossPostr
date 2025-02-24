//
//  AnimatedBackground.swift
//  crosspostr
//
//  Created by Mohamed Remo on 23.02.25.
//
import SwiftUI

struct AnimatedBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.main2, Color.main3, Color.main1]),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .animation(Animation.linear(duration: 8).repeatForever(autoreverses: true), value: animateGradient)
        .onAppear {
            animateGradient = true
        }
    }
}
