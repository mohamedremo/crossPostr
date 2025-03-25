import SwiftUI

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.7
    @State private var fadeOut = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .scaleEffect(scale)
                .opacity(fadeOut ? 0 : 1)
                .onAppear {
                    withAnimation(.easeOut(duration: 1)) {
                        scale = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        withAnimation(.easeIn(duration: 0.5)) {
                            fadeOut = true
                        }
                    }
                }
        }
    }
}
