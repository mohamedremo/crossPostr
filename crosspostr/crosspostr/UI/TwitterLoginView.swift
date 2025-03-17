//
//  TwitterLoginView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 17.03.25.
//
import KeychainAccess
import SwiftUI

struct TwitterLoginView: View {
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Text("Twitter-Login")
                .font(.headline)
            
            Spacer().frame(height: 20)
            
            if let errorMessage = errorMessage {
                Text("Fehler: \(errorMessage)")
                    .foregroundColor(.red)
            }
            
            if isLoading {
                ProgressView("Bitte warten...")
            } else {
                Button("Mit Twitter anmelden") {
                    Task {
                        await loginWithTwitter()
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func loginWithTwitter() async {
        isLoading = true
        errorMessage = nil
        
        // OAuthManager ist dein zentraler Manager
        let oauthManager = OAuthManager.shared
        
        // Unsere Hilfsmethode (aus OAuthManager.swift), die wir vorher angelegt haben
        oauthManager.loginTwitter { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let token):
                    print("Erfolg! Token: \(token)")
                    do {
                        let keychain = Keychain(service: "com.crosspostr.oauth")
                        try keychain.set(token, key: "twitterAccessToken")
                    } catch {
                        self.errorMessage = "Fehler beim Speichern in Keychain: \(error.localizedDescription)"
                    }
                case .failure(let error):
                    print("Fehler beim Login: \(error)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
