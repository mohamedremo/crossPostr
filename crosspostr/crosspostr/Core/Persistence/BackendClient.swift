//
//  BackendClient.swift
//  crossPostr
//
//  Description: Singleton client to manage backend services (Supabase & Firebase).
//  Author: Mohamed Remo
//  Version: 1.0
//

import Foundation
import FirebaseAuth
import Supabase

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
    static let shared: BackendClient = BackendClient()
    /// The singleton instance of the `BackendClient`.

    private init() {}
    /// Private initializer to enforce the singleton pattern.

    // MARK: - Supabase
    /// The `SupabaseClient` instance to interact with Supabase backend services.
    let supabase = SupabaseClient(
        supabaseURL: URL(string: APIHost.supabase.rawValue)!,
        supabaseKey: APIKey.supabase.rawValue)

    // MARK: - Firebase
    /// The `Auth` instance from Firebase used for user authentication.
    let auth = Auth.auth()
}
