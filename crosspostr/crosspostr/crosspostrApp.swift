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
            ContentView(authVM: authVM, tabVM: tabVM)
                .onOpenURL(perform: handleOpenURL) /// For Google OAuth
        }
    }

    func handleOpenURL(url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
}
