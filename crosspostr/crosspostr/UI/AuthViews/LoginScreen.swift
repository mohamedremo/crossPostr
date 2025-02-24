import SwiftUI

struct LoginScreen: View {
    @ObservedObject var vM: AuthViewModel
    @EnvironmentObject var errorManager: ErrorManager

    var body: some View {
        AnimatedContainerView {
            VStack {
                HStack {
                    Spacer()
                    Image(.avatarRight)
                        .offset(y: 80)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 60)
                    .fill(AppTheme.mainBackground)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: 500,
                        alignment: .bottom
                    )
                    .padding(.vertical, -40)
                    .overlay {

                        VStack {
                            Text("Login")
                                .font(.title)
                                .shadow(radius: 6)
                            Spacer()

                            HStack {
                                Text("E-Mail")
                                    .fontWeight(.thin)
                                    .font(.footnote)
                                    .padding(.horizontal)
                                Spacer()
                            }

                            TextField("E-Mail", text: $vM.email, prompt: Text(""))
                                .textFieldStyle(.roundedBorder)
                                .background(.clear)
                                .padding(.horizontal)

                            HStack {
                                Text("Password")
                                    .fontWeight(.thin)
                                    .font(.footnote)
                                    .padding(.horizontal)
                                Spacer()
                            }

                            SecureField("Password", text: $vM.password, prompt: Text(""))
                                .textFieldStyle(.roundedBorder)
                                .background(.clear)
                                .padding(.horizontal)

                            CustomButton(
                                title: "Login",
                                action: {
                                    Task {
                                        await vM.login(
                                            email: vM.email,
                                            password: vM.password)
                                    }
                                }
                            )
                            .padding()
                            AlternativeLogins(authVM: vM)
                            Spacer()
                        }
                    }
            }
        }
        .alert("Fehler", isPresented: .constant(errorManager.currentError != nil)) {
            Button("OK", role: .cancel) { errorManager.clearError() }
        } message: {
            Text(errorManager.currentError ?? "Unbekannter Fehler")
        }
    }
}

#Preview {
    @Previewable @StateObject var vM: AuthViewModel = AuthViewModel()
    LoginScreen(vM: vM)
}
