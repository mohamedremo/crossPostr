//
//  SnapchatAuthView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 21.02.25.
//
import SwiftUI

struct SnapchatAuthView: View {
    @StateObject private var snapAuth = SnapchatAuthManager()

    var body: some View {
        VStack {
            if snapAuth.isLoggedIn {
                Text("🎉 Eingeloggt mit Snapchat!")
                    .font(.headline)
                    .padding()

                Button(action: snapAuth.logoutFromSnapchat) {
                    HStack {
                        Image(systemName: "person.fill.xmark")
                        Text("Abmelden")
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else {
                Button(action: snapAuth.loginWithSnapchat) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Mit Snapchat anmelden")
                    }
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
            }
        }
    }
}
