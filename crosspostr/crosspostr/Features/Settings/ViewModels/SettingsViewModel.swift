//
//  SettingsViewModel.swift
//  crosspostr
//
//  Description: ViewModel for managing user settings, authentication state and social platform connections.
//  Author: Mohamed Remo
//  Created on: 18.03.2025
//
import Foundation
import PhotosUI
import SwiftUI

/// Handles settings-related actions such as logout, user info access, and connecting to social media platforms like Twitter.
@MainActor
class SettingsViewModel: ObservableObject {
    private var repo = Repository.shared
    private var errorManager = ErrorManager.shared
    private var oAuthClient = OAuthManager.shared

    @Published var isLoading: Bool = false
    
    /// Returns the current user's profile from the repository.
    var mainProfile: Profile? {
        return repo.mainProfile
    }

    func connectToTwitter() {
        oAuthClient.loginTwitter { result in
            Task {
                self.isLoading = false
                switch result {
                case .success(let token):
                    print("Erfolg! Token: \(token)")
                    do {
                        try KeychainManager.shared.set(
                            token, key: "twitter_accessToken")
                    } catch {
                        self.errorManager.setError(error)
                    }
                case .failure(let error):
                    print("Fehler beim Login: \(error)")
                    self.errorManager.setError(error)
                }
            }
        }
    }
}
