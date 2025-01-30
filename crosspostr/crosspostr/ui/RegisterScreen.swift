//
//  Untitled.swift
//  crosspostr
//
//  Created by Mohamed Remo on 29.01.25.
//
import SwiftUI

struct RegisterScreen: View {
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
                    .frame(maxWidth: .infinity, maxHeight: 500,alignment: .bottom)
                    .padding(.vertical, -40)
                    .overlay {

                        VStack {
                            Text("Register")
                                .font(.title)
                                .shadow(radius: 6)
                            Spacer()

                            HStack {
                                Text("Mail")
                                    .fontWeight(.thin)
                                    .font(.caption)
                                    .padding(.horizontal)
                                    .offset(y: 4)
                                Spacer()
                            }

                            TextField(
                                "E-Mail", text: $vM.email, prompt: Text("")
                            )
                            .textFieldStyle(.roundedBorder)
                            .background(.clear)
                            .padding(.horizontal)

                            HStack {
                                Text("Repeat Password")
                                    .fontWeight(.thin)
                                    .font(.caption)
                                    .padding(.horizontal)
                                    .offset(y: 4)
                                Spacer()
                            }

                            SecureField(
                                "Password", text: $vM.password, prompt: Text("")
                            )
                            .textFieldStyle(.roundedBorder)
                            .background(.clear)
                            .padding(.horizontal)
                            
                            HStack {
                                Text("Password")
                                    .fontWeight(.thin)
                                    .font(.caption)
                                    .padding(.horizontal)
                                    .offset(y: 4)
                                Spacer()
                            }

                            SecureField(
                                "Password", text: $vM.passwordRetry, prompt: Text("")
                            )
                            .textFieldStyle(.roundedBorder)
                            .background(.clear)
                            .padding(.horizontal)


                            CustomButton(
                                title: "Register",
                                action: {
                                    if vM.checkRegister() {
                                        Task {
                                            await vM.register(email: vM.email,password: vM.password)
                                        }
                                    }
                                }
                            )
                            .padding()
                            AlternativeLogins()
                            Spacer()
                        }
                    }
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var vM: AuthViewModel = AuthViewModel()
    RegisterScreen(vM: vM)
}
