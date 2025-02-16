import SwiftUI

struct FloatingParticlesView: View {
    @State private var particles: [FloatingParticle] = (0..<10).map { _ in FloatingParticle() }

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(AppTheme.blueGradient)
                    .frame(width: particle.size, height: particle.size)
                    .opacity(particle.opacity)
                    .position(particle.position)
                    .onAppear {
                        animateParticle(particle.id)
                    }
                    .blur(radius: 8)
                    .overlay {
                        Color.white.opacity(0.3).ignoresSafeArea()
                    }
            }
        }
        .background(Color.clear) // Transparenter Hintergrund
    }

    // MARK: - Animation Logic
    private func animateParticle(_ id: UUID) {
        guard let index = particles.firstIndex(where: { $0.id == id }) else { return }

        withAnimation(
            .easeInOut(duration: Double.random(in: 4...8))
            .repeatForever(autoreverses: true)
        ) {
            particles[index].randomizePosition()
        }
    }
}

// MARK: - Floating Particle Model
struct FloatingParticle: Identifiable {
    let id = UUID()
    var position: CGPoint = CGPoint(
        x: CGFloat.random(in: 50...300),
        y: CGFloat.random(in: 50...600)
    )
    var opacity: Double = Double.random(in: 0.5...1.0) // Etwas mehr Opazität für Leuchteffekt
    var size: CGFloat = CGFloat.random(in: 20...50) // Größere Partikel für mehr Wirkung

    mutating func randomizePosition() {
        position.x += CGFloat.random(in: -50...50)
        position.y += CGFloat.random(in: -50...50)
    }
}

// MARK: - Preview
#Preview {
    FloatingParticlesView()
}
