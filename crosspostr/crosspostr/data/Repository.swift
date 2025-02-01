//
//  Repository.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//
import Foundation
import Firebase
import Supabase
import FirebaseAuth

/**
 The `Repository` class provides access to the app's data layer, handling communication
 with the backend services. It interacts with Supabase for data storage and Firebase for
 authentication. The class uses the singleton pattern to ensure a single instance
 throughout the app.

 - Properties:
    - `supabaseClient`: A reference to the `SupabaseClient` used to interact with Supabase.
    - `authClient`: A reference to the Firebase `Auth` client used for user authentication.

 - Functions:
    - `getAllDrafts()`: Fetches all drafts stored in the Supabase database.
    - `login(email:password:)`: Authenticates a user via Firebase using their email and password.

 - Author: Mohamed Remo
 - Version: 1.0
 */
@MainActor
class Repository: ObservableObject {
    // MARK: - shared instances
    
    static let shared: Repository = Repository()
    
    private init() {} /// Singleton
    
    private let supabaseClient = BackendClient.shared.supabase /// Supabase
    
    private let authClient = BackendClient.shared.auth /// Firebase Auth
    
    // MARK: - Supabase functions
    
    /**
         Fetches all drafts from the Supabase database.
         
         - Returns: A list of `Draft` objects representing the drafts stored in the database.
         - Throws: An error if the request fails.
         */
    func getAllDrafts() async throws -> [Draft] {
        let data: [Draft] = try await supabaseClient.from("drafts") /// Selects the Table
            .select("*") /// Select all fields (equivalent to SQL "SELECT *")
            .execute() /// Executes the Query and returns a response of the specified type in this case -> Draft.swift
            .value
        
        return data
    }
    
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
    
    func logout() throws {
        try? authClient.signOut()
    }
    
    func register(email: String, password: String) async throws {
        try await authClient.createUser(withEmail: email, password: password)
    }

}
