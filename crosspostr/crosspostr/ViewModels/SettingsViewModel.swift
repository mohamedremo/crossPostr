//
//  SettingsViewModel.swift
//  crosspostr
//
//  Created by Mohamed Remo on 18.03.25.
//
import Foundation
import SwiftUI
import PhotosUI

@MainActor
class SettingsViewModel: ObservableObject {
    private var repo = Repository.shared
    private var errorManager = ErrorManager.shared
    private var oauth = OAuthManager.shared
    
    
    @State var isLoading: Bool = false
    
    var mainProfile: Profile? {
        return repo.mainProfile
    }
    
    func logout() {
        do {
            try repo.logout()
        } catch {
            errorManager.setError(error)
        }
    }
    
    func connectToTwitter() {
        oauth.loginTwitter { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let token):
                    print("Erfolg! Token: \(token)")
                    do {
                        try KeychainManager.shared.set(token, key: "twitter_accessToken")
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
