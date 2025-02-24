import SwiftUI
import AuthenticationServices

/// This View provides the UI for alternative login options such as Google and Apple login.
/// It displays two buttons, one for Google login and one for Apple login. When tapped, each button
/// triggers the respective login method.
///
/// - Uses `SocialMediaButton` for each login option.
/// - Integrates `Firebase` for Google login (Google login functionality to be implemented).
/// - Integrates `Apple` sign-in using `ASAuthorizationAppleIDProvider` for Apple login.

struct AlternativeLogins: View {
    @ObservedObject var authVM: AuthViewModel
    @StateObject var SnapVM: SnapchatAuthManager = SnapchatAuthManager()
    var body: some View {
        HStack {
            Image(.lineLeft)
            Text("or login with")
                .font(.footnote)
            Image(.lineRight)
        }
        HStack {
            SocialMediaButton(image: .google, action: {
                authVM.googleSignIn()
            })
            SocialMediaButton(image: .apple, action: {
                
            })
            
        }
    }
}

struct SocialMediaButton: View {
    @State var image: ImageResource
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 60, height: 50)
                .overlay(content: {
                    Image(image)
                })
                .background(.white.opacity(0.2))
                .cornerRadius(20)
        }
    }
}
