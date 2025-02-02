//
//  crosspostrApp.swift
//  crosspostr
//
//  Created by Mohamed Remo on 20.01.25.
//

import Firebase
import GoogleSignIn
import SwiftData
import SwiftUI

@main
struct crosspostrApp: App {
    @StateObject var authVM: AuthViewModel = AuthViewModel()
    @StateObject var tabVM: TabBarViewModel = TabBarViewModel()

    // MARK: - FIREBASE - Initialisierung
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                MainTabView(tabVM: tabVM, authVM: authVM)
            } else {
                OnBoardingScreen(authVM: authVM)
                    .onOpenURL(perform: handleOpenURL)
            }
        }
    }

    func handleOpenURL(url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
}
