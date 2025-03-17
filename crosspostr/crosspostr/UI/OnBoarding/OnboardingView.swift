import SwiftUI

struct OnboardingView: View {
    @Binding var hasOnboarded: Bool
    @State private var currentPage = 0
    let totalPages = 3

    var body: some View {
        ZStack {
            // Animated gradient background.
            AnimatedBackground()

            VStack {
                Spacer()
                // Use a TabView for a paging effect.
                TabView(selection: $currentPage) {
                    // Erste Seite: Einführung in crossPostr
                    OnboardingPageView(
                        title: "Welcome to crossPostr",
                        subtitle: "Einfache Cross-Posting-Funktionen für Influencer und Social-Media-Profis.",
                        imageName: "globe"
                    )
                    .tag(0)

                    // Zweite Seite: Vorteile von crossPostr
                    OnboardingPageView(
                        title: "Post on Multiple Platforms",
                        subtitle: "Spare Zeit und erhöhe deine Reichweite durch gleichzeitiges Posten auf mehreren Plattformen.",
                        imageName: "square.stack.3d.down.forward.fill"
                    )
                    .tag(1)

                    // Dritte Seite: Highlights und Analytics
                    OnboardingPageView(
                        title: "Analyze Your Performance",
                        subtitle: "Verfolge Trends, erhalte KI-gestützte Vorschläge und optimiere deine Posting-Zeiten.",
                        imageName: "chart.bar.doc.horizontal.fill"
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Next / Get Started Button with a scaling and shadow animation.
                Button(action: {
                    if currentPage < totalPages - 1 {
                        currentPage += 1
                    } else {
                        withAnimation {
                            hasOnboarded = true
                        }
                    }
                }) {
                    Text(currentPage < totalPages - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 40)
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentPage)
                }
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
    }
}
