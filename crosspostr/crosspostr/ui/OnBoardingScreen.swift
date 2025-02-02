//
//  OnBoardingScreen.swift
//  crosspostr
//
//  Created by Mohamed Remo on 22.01.25.
//
import SwiftUI

struct OnBoardingScreen: View {
    @ObservedObject var vM: AuthViewModel
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
                            LoginScreen(vM: vM)
                        }
                    )
                    .padding(.vertical, 8)
                    
                    CustomNavigationButton(
                        title: "Register",
                        destination: {
                            LoginScreen(vM: vM)
                        }
                    )

                    HStack {
                        Image(.lineLeft)
                        Text("or login with")
                            .font(.footnote)
                        Image(.lineRight)
                    }
                    HStack {
                        SocialMediaButton(
                            image: .google,
                            action: {

                            })
                        SocialMediaButton(
                            image: .apple,
                            action: {

                            })
                    }
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }

}

struct CustomNavigationButton<Content: View>: View {
    var title: String
    @ViewBuilder var destination: () -> Content
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 147, height: 50)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(
                                    color: .white.opacity(0.9), location: 0.00),
                                Gradient.Stop(
                                    color: .white.opacity(0.6), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    .cornerRadius(20)
                Text(title)
                    .foregroundStyle(.black)
                    .font(
                        .system(size: 18, weight: .semibold, design: .rounded))
            }
        }
    }
}


struct OnBoarding: View {
    @ObservedObject var vM: AuthViewModel
    var body: some View {
        OnBoardingScreen(vM: vM)
    }
}

#Preview("OnBoardingProcess") {
    @Previewable @StateObject var vM = AuthViewModel()
    OnBoarding(vM: vM)
}

#Preview {
    @Previewable @StateObject var vM = AuthViewModel()
    OnBoardingScreen(vM: vM)
}
