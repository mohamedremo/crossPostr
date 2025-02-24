//
//  SnapchatAuthManager.swift
//  crosspostr
//
//  Created by Mohamed Remo on 21.02.25.
//
import SwiftUI
import SCSDKLoginKit

class SnapchatAuthManager: ObservableObject {
    @Published var isLoggedIn = SCSDKLoginClient.isUserLoggedIn
    @Published var errorMessage: String?

    func loginWithSnapchat() {
        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
            print("❌ Kein Root ViewController gefunden!")
            return
        }

        SCSDKLoginClient.login(from: rootVC) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isLoggedIn = true
                    print("✅ Snapchat Login erfolgreich!")
                } else {
                    self.errorMessage = error?.localizedDescription ?? "Unbekannter Fehler"
                    print("❌ Fehler bei Snapchat Login: \(self.errorMessage ?? "Unbekannt")")
                }
            }
        }
    }

    func logoutFromSnapchat() {
        SCSDKLoginClient.clearToken()
        isLoggedIn = false
        print("🚪 Abgemeldet von Snapchat!")
    }
}
