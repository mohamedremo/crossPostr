import FirebaseAuth
import Foundation
import GoogleSignIn
import GoogleSignInSwift

/**
 The `AuthViewModel` class manages authentication logic, including email/password
 login, registration, and Google Sign-In. It interacts with the `Repository` and `Utils` class,
 which handles authentication via Firebase and get Helpers from the Utils Class.

 - Properties:
    - `repo`: Shared instance of `Repository` for authentication operations.
    - `user`: Published property representing the currently logged-in user.
    - `email`, `password`, `passwordRetry`: Published properties for user credentials.
    - `isLoggedIn`: Computed property that checks if a user is currently authenticated.

 - Functions:
    - `login(email:password:)`: Authenticates a user via Firebase.
    - `logout()`: Logs out the current user.
    - `checkRegister()`: Validates email format and password match before registration.
    - `register(email:password:)`: Registers a new user with Firebase Auth.
    - `resetStates()`: Resets user input fields.
    - `isValidEmail()`: Validates the email format.
    - `googleSignIn()`: Handles Google OAuth authentication and retrieves user information.

 - Author: Mohamed Remo
 - Version: 1.0
 */
@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Properties
    
    private var repo = Repository.shared
    
    @Published var user: User?
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordRetry: String = ""
    
    /// Checks if a user is currently logged in
    var isLoggedIn: Bool {
        return repo.currentUser != nil
    }
    
    // MARK: - Authentication Functions
    
    /**
     Logs in a user using Firebase Authentication.
     
     - Parameters:
        - email: The user's email address.
        - password: The user's password.
     */
    func login(email: String, password: String) async {
        do {
            try await repo.login(email: email, password: password)
            self.resetStates()
            self.user = self.repo.currentUser
            print("Login Successful")
            print(self.user?.email ?? "No User set")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Logs out the current user and resets user state.
    func logout() {
        do {
            try repo.logout()
            self.user = nil
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /**
     Validates registration by checking if the email format is correct and passwords match.
     
     - Returns: `true` if the email is valid and passwords match, otherwise `false`.
     */
    func checkRegister() -> Bool {
        if isValidEmail() && self.password == self.passwordRetry {
            print("CheckRegister() -> true")
            return true
        } else {
            print("CheckRegister() -> false - !!Email or Password not valid")
            return false
        }
    }
    
    /**
     Registers a new user in Firebase Authentication.
     
     - Parameters:
        - email: The user's email address.
        - password: The chosen password.
     */
    func register(email: String, password: String) async {
        do {
            try await repo.register(email: email, password: password)
            self.resetStates()
            self.user = repo.currentUser
            print("Register Successful with Email: \(email)")
            print(self.user?.email ?? "No User set")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Resets email and password fields.
    func resetStates() {
        self.email = ""
        self.password = ""
        self.passwordRetry = ""
    }
    
    /**
     Validates the email format using a regular expression.
     
     - Returns: `true` if the email format is valid, otherwise `false`.
     */
    func isValidEmail() -> Bool {
        let regex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self.email)
    }
    
    /// Login with Google
    func googleSignIn() {
        Task {
            do {
                try await repo.googleSignIn()
                self.user = repo.currentUser
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
