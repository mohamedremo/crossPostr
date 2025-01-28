//
//  SupabaseClient.swift
//  crosspostr
//
//  Created by Mohamed Remo on 23.01.25.
//

import Foundation
import Supabase
import FirebaseAuth

/**
 The `BackendClient` class provides a singleton instance that manages interactions
 with the backend services, including Supabase for database access and Firebase for authentication.
 This class ensures that there is only one instance of the client used throughout the app.

 - Properties:
    - `supabase`: A `SupabaseClient` instance that connects to Supabase for backend operations.
    - `auth`: An `Auth` instance from Firebase used for handling user authentication.

 - Author: Mohamed Remo
 - Version: 1.0
 */

struct BackendClient {
    /// The singleton instance of the `BackendClient`.
    static let shared: BackendClient = BackendClient()
    
    private init() {} /// ensures singleton
    
    // MARK: - Supabase
    /// The `SupabaseClient` instance to interact with Supabase backend services.
    let supabase = SupabaseClient(
        supabaseURL: URL(string: apiHost.supabase.rawValue)!,
        supabaseKey: apiKey.supabase.rawValue)
    
    // MARK: - Firebase
    /// The `Auth` instance from Firebase used for user authentication.
    let auth = Auth.auth()
}
