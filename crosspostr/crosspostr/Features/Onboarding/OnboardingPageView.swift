import SwiftUI

struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let imageName: String

    @State private var animateText = false
    @State private var animateImage = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .scaleEffect(animateImage ? 1.0 : 0.5)
                .rotationEffect(.degrees(animateImage ? 0 : -45))
                .opacity(animateImage ? 1.0 : 0.0)
                .animation(Animation.spring(response: 1.0, dampingFraction: 0.5).delay(0.2), value: animateImage)
                .onAppear {
                    animateImage = true
                }
            
            
            Text(title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .opacity(animateText ? 1.0 : 0.0)
                .offset(y: animateText ? 0 : -20)
                .animation(Animation.easeOut(duration: 1.0).delay(0.5), value: animateText)
            

            Text(subtitle)
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .opacity(animateText ? 1.0 : 0.0)
                .offset(y: animateText ? 0 : 20)
                .animation(Animation.easeOut(duration: 1.0).delay(0.7), value: animateText)
            Spacer()
        }
        .onAppear {
            animateText = true

            animateImage = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateImage = true
            }
        }
        .onDisappear {
            
            animateText = false
            animateImage = false
        }
    }
}
