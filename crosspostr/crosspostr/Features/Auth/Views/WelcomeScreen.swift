import SwiftUI

struct WelcomeScreen: View {
    @ObservedObject var authVM: AuthViewModel
    var uiScreen = UIScreen.main.bounds
    @State private var animateGradient = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.main2, Color.main3, Color.main1,
                    ]),
                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                )
                .animation(
                    Animation.linear(duration: 8).repeatForever(
                        autoreverses: true), value: animateGradient
                )
                .onAppear {
                    animateGradient = true
                }
                .ignoresSafeArea()

                HStack {
                    Spacer()
                    Image(.avatarRightRead)
                        .resizable()
                        .frame(
                            width: uiScreen.width / 2, height: 400,
                            alignment: .trailing)
                }
                VStack {
                    Spacer()
                    InfoBox()
                        .padding(.bottom, 300)

                    CustomNavigationButton(
                        title: "Login",
                        destination: {
                            LoginScreen(vM: authVM)
                        }
                    )
                    .padding(.vertical, 8)

                    CustomNavigationButton(
                        title: "Register",
                        destination: {
                            RegisterScreen(vM: authVM)
                        }
                    )
                    AlternativeLogins(authVM: authVM)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .withErrorAlert()
    }
}

#Preview {
    @Previewable @StateObject var vM = AuthViewModel()
    WelcomeScreen(authVM: vM)
}
