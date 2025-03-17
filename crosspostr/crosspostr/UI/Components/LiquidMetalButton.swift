import SwiftUI

struct LiquidMetalButton: View {
    var action: () -> Void = {}
    @State private var isPressed = false
    @State private var gradientAngle: Angle = .degrees(0)
    
    var gradient: AngularGradient {
        AngularGradient(gradient: Gradient(colors: [.main2, .main1, .main3]), center: .center, startAngle: gradientAngle, endAngle: gradientAngle + .degrees(360))
    }
    
    var body: some View {
        return Text("crossPost!")
            .font(.system(size: 20, weight: .black))
            .foregroundStyle(gradient)
            .padding(20)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(gradient, lineWidth: 8)
                    .blur(radius: isPressed ? 20 : 8)
                    .opacity(isPressed ? 0 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: isPressed ? 30 : 15))
            .scaleEffect(isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 5).repeatForever(autoreverses: false)) {
                    gradientAngle = .degrees(360)
                }
            }
    }
}
