import FirebaseAuth
//
//  AuthViewModel.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//
import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    private var repo = Repository.shared

    @Published var user: User?
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordRetry: String = ""
    var isLoggedIn: Bool {
        return repo.currentUser != nil
    }

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

    func checkRegister() -> Bool {
        if isValidEmail() && self.password == self.passwordRetry {
            print("CheckRegister() -> true")
            return true
        } else {
            print("CheckRegister() -> false - !!Email or Password not valid")
            return false
        }
    }

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

    func resetStates() {
        self.email = ""
        self.password = ""
        self.passwordRetry = ""
    }

    func isValidEmail() -> Bool {
        let regex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(
            with: self.email)
    }
}
