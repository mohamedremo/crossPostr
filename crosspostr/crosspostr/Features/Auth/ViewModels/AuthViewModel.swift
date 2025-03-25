//
//  AuthViewModel.swift
//  crosspostr
//
//  Description: ViewModel for handling Firebase authentication logic including login, registration, session tracking and Google OAuth integration.
//  Author: Mohamed Remo
//

import FirebaseAuth
import Foundation
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

/// The `AuthViewModel` class manages authentication logic, including email/password
/// login, registration, and Google Sign-In. It interacts with the `Repository` and `Utils` class,
/// which handles authentication via Firebase and get Helpers from the Utils Class.
///
/// - Properties:
///    - `repo`: Shared instance of `Repository` for authentication operations.
///    - `user`: Published property representing the currently logged-in user.
///    - `email`, `password`, `passwordRetry`: Published properties for user credentials.
///    - `isLoggedIn`: Published property that indicates if a user is currently authenticated.
///
/// - Functions:
///    - `login(email:password:)`: Authenticates a user via Firebase.
///    - `logout()`: Logs out the current user.
///    - `checkRegister()`: Validates email format and password match before registration.
///    - `register(email:password:)`: Registers a new user with Firebase Auth.
///    - `resetStates()`: Resets user input fields.
///    - `isValidEmail()`: Validates the email format.
///    - `googleSignIn()`: Handles Google OAuth authentication and retrieves user information.
///
/// - Author: Mohamed Remo
/// - Version: 1.0
@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Properties

    /// Shared repository instance used for authentication calls.
    private var repo = Repository.shared
    /// Shared error manager for centralized error publishing.
    private var errorManager = ErrorManager.shared

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordRetry: String = ""
    @Published var isLoggedIn: Bool

    /// Returns the user's profile after successful login (if available).
    var mainProfile: Profile? {
        return repo.mainProfile
    }

    init() {
        if repo.currentUser != nil {
            self.isLoggedIn = true
        } else {
            self.isLoggedIn = false
        }
    }

    // MARK: - Authentication Functions

    /**
     Logs in a user using Firebase Authentication.

     - Parameters:
        - email: The user's email address.
        - password: The user's password.
     */
    func login(email: String, password: String) {
        guard isValidEmailFormat(email) else {
            errorManager.setError(AuthError.invalidEmail)
            return
        }
        guard !password.isEmpty else {
            errorManager.setError(AuthError.emptyPassword)
            return
        }
        Task {
            await repo.login(email: email, password: password)
            isLoggedIn = true
            resetStates()
            print("Login Successful")
        }
    }

    /// Logs out the current user and resets user state.
    func logout() {
        repo.logout()
        isLoggedIn = false
    }

    /**
     Validates registration by checking if the email format is correct and passwords match.

     - Returns: `true` if the email is valid and passwords match, otherwise `false`.
     */
    func checkRegister() -> Bool {
        if isValidEmailFormat(email) && password == passwordRetry {
            print("CheckRegister() -> true")
            return true
        } else {
            print("CheckRegister() -> false - Email or Password not valid!")
            return false
        }
    }

    /**
     Registers a new user in Firebase Authentication.

     - Parameters:
        - email: The user's email address.
        - password: The chosen password.
     */
    func register(email: String, password: String) {
        guard isValidEmailFormat(email) else {
            errorManager.setError(AuthError.invalidEmail)
            return
        }
        guard password == passwordRetry else {
            errorManager.setError(AuthError.passwordMismatch)
            return
        }
        guard password.count >= 6 else {
            errorManager.setError(AuthError.passwordTooShort)
            return
        }

        Task {
            await repo.register(email: email, password: password)
            resetStates()
            isLoggedIn = true
            print("Register Successful with Email: \(email)")
        }
    }

    /// Resets email and password fields.
    func resetStates() {
        email = ""
        password = ""
        passwordRetry = ""
    }

    /**
     Validates the email format using a regular expression.

     - Returns: `true` if the email format is valid, otherwise `false`.
     */
    private func isValidEmailFormat(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(
            with: email)
    }

    /**
     Initiates Google OAuth Sign-In flow and updates the user session.
     If successful, the user will be authenticated and available through `repo.currentUser`.
     */
    func googleSignIn() {
        Task {
            await repo.googleSignIn()
            isLoggedIn = true
        }
    }

    /// Attempts to restore the previous Google Sign-In session if available.
    func restoreSession() {
        repo.restoreSignIn()
    }
}
