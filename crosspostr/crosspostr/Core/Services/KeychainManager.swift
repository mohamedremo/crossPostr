//
//  KeychainManager.swift
//  crosspostr
//
//  Description: Manages secure storage and retrieval of sensitive user data using KeychainAccess.
//  Author: Mohamed Remo
//  Created on: 18.03.2025
//

import KeychainAccess

/// Manages secure storage and retrieval of sensitive user data using the Keychain.
final class KeychainManager {
    
    // MARK: - Initialization

    /// Shared Keychain instance scoped to the app's bundle identifier.
    static let shared = Keychain(service: "com.remo.crosspostr")
    
    private init(){}
}
