//
//  AuthViewModel.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//
import Foundation
import FirebaseAuth
import SwiftUI

class AuthViewModel: ObservableObject {
    private var repo = Repository.shared
    
    @Published var user: User?
    @Published var email: String = ""
    @Published var password: String = ""
    
    
    func login(email: String, password: String) async {
        do {
            try await repo.login(email: email, password: password)
            self.resetStates()
            print("Login Successful")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func resetStates() {
        self.email = ""
        self.password = ""
    }
}
