import SwiftUI

struct OnBoardingScreen: View {
    @ObservedObject var authVM: AuthViewModel
    var uiScreen = UIScreen.main.bounds
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.blueGradient.ignoresSafeArea()
                HStack {
                    Spacer()
                    Image(.avatarRightRead)
                        .resizable()
                        .frame(width: uiScreen.width/2, height: 400, alignment: .trailing)
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
                            LoginScreen(vM: authVM)
                        }
                    )
                    AlternativeLogins(authVM: authVM)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }

}

#Preview {
    @Previewable @StateObject var vM = AuthViewModel()
    OnBoardingScreen(authVM: vM)
}
