//
//  OAuthProvider.swift
//  crosspostr
//
//  Description: Defines supported OAuth providers and their associated configuration details.
//  Author: Mohamed Remo
//  Created on: 22.03.2025
//

import Foundation

/// Represents supported OAuth providers and their associated configuration values such as client ID, URLs, scopes, and secrets.
enum OAuthProvider: String, CaseIterable {
    case facebook = "facebook"
    case twitter = "twitter"
    case instagram = "instagram"
    
    /// The client ID registered for the specific OAuth provider.
    var clientId: String {
        switch self {
        case .facebook:  return "<FACEBOOK_CLIENT_ID>"
        case .twitter:   return "YXEwbVhwM21ZVVpSLWVuZlh0dE06MTpjaQ"
        case .instagram: return "<INSTAGRAM_CLIENT_ID>"
        }
    }
    
    /// The authorization endpoint URL used to initiate the OAuth flow.
    var authorizationURL: String {
        switch self {
        case .facebook:
            return "https://www.facebook.com/v15.0/dialog/oauth"
        case .twitter:
            return "https://twitter.com/i/oauth2/authorize"
        case .instagram:
            return "https://api.instagram.com/oauth/authorize?provider=instagram"
        }
    }
    
    /// The token endpoint URL used to exchange authorization code for an access token.
    var token: String {
        switch self {
        case .facebook:
            return "<FACEBOOK_ACCESS_TOKEN>"
        case .twitter:
            return "https://api.twitter.com/2/oauth2/token"
        case .instagram:
            return "<INSTAGRAM_ACCESS_TOKEN>"
        }
    }
    
    /// A space-separated list of scopes required by the provider.
    var scopes: String {
        switch self {
        case .facebook:  return "public_profile,email"
        case .twitter:   return "tweet.write tweet.read users.read offline.access"
        case .instagram: return "user_profile,user_media"
        }
    }
    
    /// The custom URL scheme registered in Info.plist to handle redirect callback.
    var redirectScheme: String { "crosspostr" }
    
    /// The full redirect URI used during OAuth configuration.
    var redirectURI: String { "crosspostr://callback" }
    
    /// The client secret associated with the provider (should be stored securely).
    var clientSecret: String {
        switch self {
        case .facebook:
            return "<FACEBOOK_CLIENT_SECRET>"
        case .twitter:
            return "gFX9vccpa1PVZYlqFYmFa6SZy8EzB0G_7XbwRGb6OXJ4YvXt3P"
        case .instagram:
            return "<INSTAGRAM_CLIENT_SECRET>"
        }
    }
}
