import SwiftUI

struct CustomNavigationButton<Content: View>: View {
    var title: String
    @ViewBuilder var destination: () -> Content
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 147, height: 50)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(
                                    color: .white.opacity(0.9), location: 0.00),
                                Gradient.Stop(
                                    color: .white.opacity(0.6), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    .cornerRadius(20)
                Text(title)
                    .foregroundStyle(.black)
                    .font(
                        .system(size: 18, weight: .semibold, design: .rounded))
            }
        }
    }
}
