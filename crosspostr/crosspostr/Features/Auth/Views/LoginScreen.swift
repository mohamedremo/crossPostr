import SwiftUI

struct LoginScreen: View {
    @ObservedObject var vM: AuthViewModel
    @FocusState private var isInputActive: Bool
    private let height = UIScreen.main.bounds.height

    var body: some View {
        AnimatedContainerView {
            VStack {
                HStack {
                    Spacer()
                    Image(.avatarRight)
                        .offset(y: isInputActive ? height * 0.02 : height * 0.2)
                        .animation(
                            .easeInOut(duration: 0.3), value: isInputActive)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 60)
                    .fill(
                        isInputActive
                            ? AppTheme.cardGradient : AppTheme.buttonGradient
                    )
                    .animation(.easeInOut(duration: 0.3), value: isInputActive)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .offset(y: isInputActive ? -height * 0.10 : height * 0.10)
                    .padding(.vertical, -height * 0.05)
                    .ignoresSafeArea()
                    .overlay {
                        VStack {
                            Spacer()
                            HStack {
                                Text("E-Mail")
                                    .fontWeight(.thin)
                                    .font(.footnote)
                                    .padding(.horizontal)
                                Spacer()
                            }

                            TextField(
                                "E-Mail", text: $vM.email, prompt: Text("")
                            )
                            .textFieldStyle(.roundedBorder)
                            .background(.clear)
                            .padding(.horizontal)
                            .focused($isInputActive)

                            HStack {
                                Text("Password")
                                    .fontWeight(.thin)
                                    .font(.footnote)
                                    .padding(.horizontal)
                                Spacer()
                            }

                            SecureField(
                                "Password", text: $vM.password, prompt: Text("")
                            )
                            .textFieldStyle(.roundedBorder)
                            .background(.clear)
                            .padding(.horizontal)
                            .focused($isInputActive)

                            CustomButton(
                                title: "Login",
                                action: {
                                    vM.login(
                                        email: vM.email,
                                        password: vM.password
                                    )
                                }
                            )
                            .padding()
                            AlternativeLogins(authVM: vM)
                            Spacer()
                        }
                    }
            }
        }
        .dismissKeyboardOnTap()
    }
}

#Preview {
    @Previewable @StateObject var vM: AuthViewModel = AuthViewModel()
    LoginScreen(vM: vM)
}
