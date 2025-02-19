//
//  Repository.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//

// MARK: - Repository Class
/**
 The `Repository` class manages the app's data layer, handling communication
 with Supabase for data storage and Firebase for authentication.
 It follows the singleton pattern to ensure a single instance is used throughout the app.

 ## Responsibilities:
 - Fetches and manages draft posts from Supabase.
 - Handles user authentication via Firebase and Google Sign-In.
 - Ensures efficient data retrieval and state management.

 ## Properties:
 - `supabaseClient`: Interface for interacting with Supabase.
 - `authClient`: Firebase authentication client.

 ## Functions:
 - `getAllDrafts()`: Retrieves all stored drafts from Supabase.
 - `login(email:password:)`: Authenticates a user via Firebase with email and password.
 - `googleSignIn()`: Handles authentication via Google Sign-In and Firebase.

 ## Author:
 - Mohamed Remo
 - Version: 1.0
 */
import Firebase
import FirebaseAuth
import Foundation
import GoogleSignIn
import Supabase
import SwiftData

@MainActor
class Repository {
    // MARK: - shared instances

    static let shared: Repository = Repository()
    let remoteRepository: RemoteRepository = RemoteRepository()
    let localRepository: LocalRepository = LocalRepository()

    private init() {}

    
    // MARK: - Firebase functions
    private let authClient = BackendClient.shared.auth
    
    var currentUser: FirebaseAuth.User? {
        return authClient.currentUser
    }

    /**
        Logs in a user using their email and password through Firebase Auth.

        - Parameters:
           - email: The email address of the user.
           - password: The password for the user's account.

        - Throws: An error if the authentication fails.
        */
    func login(email: String, password: String) async throws {
        try await authClient.signIn(withEmail: email, password: password)
    }

    /// Logs out the current user.
    func logout() throws {
        try? authClient.signOut()
    }

    /// Registers a new user in Firebase Authentication.
    func register(email: String, password: String) async throws {
        try await authClient.createUser(withEmail: email, password: password)
    }

    // MARK:  Google OAuth Sign-In

    /**
     Handles Google Sign-In authentication and integrates it with Firebase.

     - Throws:
        - `AuthError.noRootViewController`: If the root view controller cannot be found.
        - `AuthError.missingIDToken`: If the Google authentication result does not contain an ID token.
        - An error from Firebase authentication if the sign-in process fails.


     - Example usage:
        ```swift
        Task {
            do {
                try await Repository.shared.googleSignIn()
            } catch {
                print("Google Sign-In failed: \(error.localizedDescription)")
            }
        }
        ```
     */
    enum AuthError: Error {
        case noRootViewController
        case missingIDToken
    }

    func googleSignIn() async throws {
        guard let rootViewController = Utils.shared.getRootViewController()
        else {
            throw AuthError.noRootViewController
        }

        let signInResult = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController)

        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw AuthError.missingIDToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: signInResult.user.accessToken.tokenString
        )

        // Authenticate with Firebase
        let authResult = try await authClient.signIn(with: credential)

        // Optional: Create a profile instance
        let profile = Profile(
            id: signInResult.user.userID ?? UUID().uuidString,
            firstName: signInResult.user.profile?.givenName ?? "Unknown",
            fullName: signInResult.user.profile?.name ?? "Unknown",
            email: signInResult.user.profile?.email ?? "no-email@example.com",
            birthDate: nil,
            profileImageUrl: nil
        )

        print(
            "Google Sign-In successful. Firebase User: \(self.authClient.currentUser?.email ?? "No Email")"
        )
        print("New Profile \(profile) has been created.")
    }

    func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            guard error == nil else {
                print("Keine authentifizierte Person gefunden")
                return
            }
        }
    }
}
