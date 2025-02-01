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
                TabBarView(vM: tabVM) {
                    switch tabVM.selectedPage {
                    case .home:
                        Button("Logout") {
                            authVM.logout()
                        }
                    case .create: Text("Create")
                    case .settings: Text("Settings")
                    }
                }
            } else {
                OnBoarding(vM: authVM)
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
            }
        }
    }
}
