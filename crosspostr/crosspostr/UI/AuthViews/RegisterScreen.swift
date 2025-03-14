import SwiftUI

struct RegisterScreen: View {
    @ObservedObject var vM: AuthViewModel
    @EnvironmentObject var errorManager: ErrorManager
    @FocusState private var isInputActive: Bool
    private let height = UIScreen.main.bounds.height

    var body: some View {
        AnimatedContainerView {
            VStack {
                HStack {
                    Spacer()
                    Image(.avatarRight)
                        .offset(y: isInputActive ? height * 0.02 : height * 0.2)
                        .animation(.easeInOut(duration: 0.3), value: isInputActive)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 60)
                    .fill(isInputActive ? AppTheme.mainBackground : AppTheme.cardGradient)
                    .animation(.bouncy(duration: 0.2), value: isInputActive)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .offset(y: isInputActive ? -height * 0.13 : height * 0.06)
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

                            TextField("E-Mail", text: $vM.email, prompt: Text(""))
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

                            SecureField("Password", text: $vM.password, prompt: Text(""))
                                .textFieldStyle(.roundedBorder)
                                .background(.clear)
                                .padding(.horizontal)
                                .focused($isInputActive)
                            
                            HStack {
                                Text("Confirm password")
                                    .fontWeight(.thin)
                                    .font(.footnote)
                                    .padding(.horizontal)
                                Spacer()
                            }
                            
                            SecureField("Password", text: $vM.password, prompt: Text(""))
                                .textFieldStyle(.roundedBorder)
                                .background(.clear)
                                .padding(.horizontal)
                                .focused($isInputActive)

                            CustomButton(
                                title: "Register",
                                action: {
                                    if vM.checkRegister() {
                                        errorManager.setError("Passwords do not match!" as! Error)
                                        return
                                    }
                                    
                                    Task {
                                        await vM.register(
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
    @Previewable @StateObject var vM: AuthViewModel = AuthViewModel()
    @Previewable @StateObject var errorHandler: ErrorManager = ErrorManager.shared
    RegisterScreen(vM: vM)
        .environmentObject(errorHandler)
}
