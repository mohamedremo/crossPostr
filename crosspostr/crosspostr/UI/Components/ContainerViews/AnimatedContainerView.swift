//
//  AnimatedBackgroundView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//
import Foundation
import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
}

struct AnimatedContainerView<Content: View>: View {
    @StateObject var vM: AnimatedContainerViewModel = AnimatedContainerViewModel()
    @ViewBuilder var content: () -> Content
    var blur: CGFloat
    
    init(
        blur: CGFloat = 6,
        @ViewBuilder content: @escaping () -> Content
    ){
        self.blur = blur
        self.content = content
    }
    
    var body: some View {
        ZStack {
            AppTheme.mainBackground.ignoresSafeArea()
            
            Canvas { context, size in
                for particle in vM.particles {
                    let rect = CGRect(
                        x: particle.x * size.width,
                        y: particle.y * size.height,
                        width: particle.size,
                        height: particle.size
                    )
                    context.fill(Ellipse().path(in: rect), with: .color(.white.opacity(0.6)))
                }
            }
            .blur(radius: blur)
            .overlay(Color.black.opacity(0.4))
            .ignoresSafeArea()
            .onAppear {
                vM.initializeParticles()
            }
            .onReceive(vM.timer) { _ in
                vM.updateParticles()
            }
            content()
        }
    }
}
