import SwiftUI

struct WelcomeScreen: View {
    @ObservedObject var authVM: AuthViewModel
    var uiScreen = UIScreen.main.bounds
    @EnvironmentObject var errorManager: ErrorManager
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
                                .environmentObject(errorManager)
                        }
                    )
                    .padding(.vertical, 8)

                    CustomNavigationButton(
                        title: "Register",
                        destination: {
                            RegisterScreen(vM: authVM)
                                .environmentObject(errorManager)
                                
                        }
                    )
                    AlternativeLogins(authVM: authVM)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .alert(item: $errorManager.currentError) { error in
            Alert(
                title: Text("Fehler"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"), action: {
                    errorManager.clearError()
                })
            )
        }
    }
}

#Preview {
    @Previewable @StateObject var vM = AuthViewModel()
    @Previewable @StateObject var errorManager = ErrorManager.shared
    WelcomeScreen(authVM: vM)
        .environmentObject(errorManager)
}
