import SwiftUI

struct AnimatedBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.main2, .main3, .main1]),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .animation(Animation.linear(duration: 8).repeatForever(autoreverses: true), value: animateGradient)
        .onAppear {
            animateGradient = true
        }
    }
}
