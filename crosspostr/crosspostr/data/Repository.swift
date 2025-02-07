import Firebase
import FirebaseAuth
import Foundation
import GoogleSignIn
import Supabase

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
@MainActor
class Repository: ObservableObject {
    // MARK: - shared instances

    static let shared: Repository = Repository()

    private init() {}
    /// Singleton

    private let supabaseClient = BackendClient.shared.supabase
    /// Supabase

    private let authClient = BackendClient.shared.auth
    /// Firebase Auth

    // MARK: - Supabase functions

    /**
         Fetches all drafts from the Supabase database.

         - Returns: A list of `Draft` objects representing the drafts stored in the database.
         - Throws: An error if the request fails.
         */
//    func getAllDrafts() async throws -> [Draft] {
//        let data: [Draft] = try await supabaseClient.from("drafts")
//            /// Selects the Table
//            .select("*")/// Select all fields (equivalent to SQL "SELECT *")
//            .execute()
//            /// Executes the Query and returns a response of the specified type in this case -> Draft.swift
//            .value
//
//        return data
//    }

    // MARK: - Firebase functions

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
            id: signInResult.user.userID ?? "",
            firstName: signInResult.user.profile?.givenName ?? "",
            fullName: signInResult.user.profile?.name ?? "",
            email: signInResult.user.profile?.email ?? ""
        )

        print(
            "Google Sign-In successful. Firebase User: \(self.authClient.currentUser?.email ?? "No Email")"
        )
        print("New Profile \(profile) has been created.")
    }

    func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            guard let user = user else {
                print("Keine authentifizierte Person gefunden")
                return
            }
        }
    }

}
