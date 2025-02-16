//
//  AnimatedContainerViewModel.swift
//  crosspostr
//
//  Created by Mohamed Remo on 02.02.25.

import Foundation
import SwiftUI

class AnimatedContainerViewModel: ObservableObject {
    @Published var particles: [Particle] = []
    let particleCount = 50
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    // Initialisiert Partikel zufällig
    func initializeParticles() {
        self.particles = (0..<self.particleCount).map { _ in
            Particle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 15...30),
                speed: CGFloat.random(in: 0.0001...0.001)
            )
        }
    }

    // Aktualisiert die Positionen der Partikel
    func updateParticles() {
        for index in self.particles.indices {
            self.particles[index].y += self.particles[index].speed
            if self.particles[index].y > 1 {
                self.particles[index].y = 0
                self.particles[index].x = CGFloat.random(in: 0...1)
            }
        }
    }
}
