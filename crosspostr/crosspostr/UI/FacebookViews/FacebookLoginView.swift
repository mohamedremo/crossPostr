//
//  FacebookLoginView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 21.02.25.
//
import SwiftUI
import AuthenticationServices

struct FacebookLoginView: View {
    @State private var showingWebView = false
    @State private var accessToken: String?

    var body: some View {
        VStack {
            if let token = accessToken {
                Text("✅ Access Token erhalten!")
                Text(token).lineLimit(1)
            } else {
                Button("Mit Facebook einloggen") {
                    openFacebookLogin()
                }
            }
        }
    }

    func openFacebookLogin() {
        let appID = "501664873040786"
        let redirectURI = "fb501664873040786://auth" // Wichtig! Muss zu Info.plist passen
        let loginURL = "https://www.facebook.com/v22.0/dialog/oauth?client_id=\(appID)&redirect_uri=\(redirectURI)&scope=publish_video&response_type=token"
        
        if let url = URL(string: loginURL) {
            UIApplication.shared.open(url)
        }
    }
}
