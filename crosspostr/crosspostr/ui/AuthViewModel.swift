import FirebaseAuth
//
//  AuthViewModel.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//
import Foundation
import GoogleSignIn
import GoogleSignInSwift

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
    
    func logout() {
        do {
            try repo.logout()
            self.user = nil
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
    
    
    // MARK: - Google OAuth SignIn
    func googleSignIn() {
        if let rootViewController = getRootViewController() {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController) { signInResult, error in
                    guard let result = signInResult else {
                        print(error?.localizedDescription ?? "Unknown Error")
                        return
                    }
                    // TODO: Hier User setzen.(Evtl. ein Model dafür anlegen.)
                    print(result.user.profile?.email ?? "No Email set")
                    print(result.user.profile?.name ?? "No Name set")
                }
        }
    }
     
    func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as?
                UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            return nil
        }
        return getVisibleViewController(from: rootViewController)
    }

    func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        if let nav = vc as? UINavigationController {
            return getVisibleViewController(from: nav.visibleViewController!)
        }
        if let tab = vc as? UITabBarController {
            return getVisibleViewController(from: tab.selectedViewController!)
        }
        if let presented = vc.presentedViewController {
            return getVisibleViewController(from: presented)
        }
        return vc
    }
    
}

