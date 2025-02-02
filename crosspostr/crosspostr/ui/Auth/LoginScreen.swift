import Lottie
//
//  LoginScreen.swift
//  crosspostr
//
//  Created by Mohamed Remo on 25.01.25.
//
import SwiftUI

struct LoginScreen: View {
    @ObservedObject var vM: AuthViewModel

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
                    .fill(AppTheme.blueGradient)
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
                                        print("login Succesful")
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
    }
}

#Preview {
    @Previewable @StateObject var vM: AuthViewModel = AuthViewModel()
    LoginScreen(vM: vM)
}
