//
//  Repository.swift
//  crossPostr
//
//  Beschreibung: Verwaltung der gesamten Datenlage der App inklusive Kommunikation mit Supabase, Firebase und GoogleSignIn.
//  Author: Mohamed Remo
//  Version: 1.0
//

import Firebase
import FirebaseAuth
import Foundation
import GoogleSignIn
import Supabase
import SwiftData
import SwiftUI

// MARK: - Shared Instances
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

@MainActor
class Repository {
    /// Singleton instance for global repository access
    static let shared: Repository = Repository()

    /// Firebase Auth client from the shared backend client
    private let authClient = BackendClient.shared.auth

    /// Remote data source (e.g., Supabase)
    let remoteRepository: RemoteRepository = RemoteRepository()

    /// Local data source
    let localRepository: LocalRepository = LocalRepository()

    /// ErrorManage Shared
    let errorManager: ErrorManager = ErrorManager.shared

    private init() {}

    /// Currently authenticated Firebase user
    var currentUser: FirebaseAuth.User? {
        return authClient.currentUser
    }

    var mainProfile: Profile?

    // MARK: - Profile

    // MARK: - Authentication Methods

    /**
        Logs in a user using their email and password through Firebase Auth.

        - Parameters:
           - email: The email address of the user.
           - password: The password for the user's account.

        - Throws: An error if the authentication fails.
        */
    func login(email: String, password: String) async {
        do {
            try await authClient.signIn(withEmail: email, password: password)
        } catch {
            errorManager.setError(error)
        }
    }

    /**
        Logs out a User

        - Throws: An error if the Logout fails.
        */
    func logout() {
        do {
            try authClient.signOut()
        } catch {
            errorManager.setError(error)
        }
    }
    //TODO: - Implementieren
    func sendPasswordReset(email: String) async {
        do {
            try await authClient.sendPasswordReset(withEmail: email)
        } catch {
            errorManager.setError(error)
        }
    }

    /**
        Register a new User using their email and password through Firebase Auth.

        - Parameters:
           - email: The email address of the user.
           - password: The password for the user's account.

        - Throws: An error if the authentication fails.
        */
    func register(email: String, password: String) async {
        do {
            try await authClient.createUser(
                withEmail: email, password: password)
        } catch {
            errorManager.setError(error)
        }
    }

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
    func googleSignIn() async {
        do {
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

            try await authClient.signIn(with: credential)

            await loadOrCreateUserProfile(signInResult: signInResult)

            print(
                "Google Sign-In successful. Firebase User: \(self.authClient.currentUser?.email ?? "No Email")"
            )
        } catch {
            errorManager.setError(error)
        }
    }

    private func loadOrCreateUserProfile(signInResult: GIDSignInResult) async {
        if let existingProfileDTO =
            await remoteRepository.getProfileObjectRemote()
        {
            mainProfile = existingProfileDTO.toProfile()
            print("profil \(existingProfileDTO) bei Supabase gefunden")
        } else {
            let newProfile = Profile(
                id: authClient.currentUser?.uid ?? "",
                firstName: signInResult.user.profile?.givenName ?? "Unknown",
                fullName: signInResult.user.profile?.name ?? "Unknown",
                email: signInResult.user.profile?.email
                    ?? "no-email@example.com",
                profileImageUrl: ""
            )
            await remoteRepository.insertProfileObjectRemote(
                newProfile: newProfile.toProfileDTO())
            mainProfile = newProfile
            print("Kein profil gefunden neues erstellt.")
        }
    }

    /**
     Handles Google's Restore Sign-In authentication and integrates it with Firebase.
     If someone is already logged in the : error = nil
     */
    func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            guard error == nil else {
                print("No authenticated user found")
                return
            }
        }
    }
}
