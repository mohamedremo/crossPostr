//
//  OnBoardingScreen.swift
//  crosspostr
//
//  Created by Mohamed Remo on 22.01.25.
//
import SwiftUI

struct OnBoardingScreen: View {

    var body: some View {
        ZStack {
            AppTheme.blueGradient.ignoresSafeArea()
            HStack {
                Spacer()
                Image(.avatarRightRead)
                    .resizable()
                    .scaledToFit()
                    .frame(width: .infinity, height: 450)
            }

            VStack {
                Spacer()
                InfoBox()
                    .padding(.bottom, 300)
                CustomButton(
                    title: "Jetzt Starten!",
                    action: {
                        //BUTTON LOGIK
                    }
                )
                .padding(.vertical, 30)

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
        .ignoresSafeArea()
    }

}

#Preview {
    OnBoardingScreen()
}
