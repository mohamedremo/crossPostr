//
//  KeychainManager.swift
//  crosspostr
//
//  Created by Mohamed Remo on 18.03.25.
//
import KeychainAccess

final class KeychainManager {
    static let shared = Keychain(service: "com.remo.crosspostr")
    
    private init(){}
}
