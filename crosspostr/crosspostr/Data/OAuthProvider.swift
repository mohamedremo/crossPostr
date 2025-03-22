//
//  OAuthProvider.swift
//  crosspostr
//
//  Created by Mohamed Remo on 22.03.25.
//
import Foundation

enum OAuthProvider: String, CaseIterable {
    case facebook = "facebook"
    case twitter = "twitter"
    case instagram = "instagram"
    
    var clientId: String {
        switch self {
        case .facebook:  return "<FACEBOOK_CLIENT_ID>"
        case .twitter:   return "YXEwbVhwM21ZVVpSLWVuZlh0dE06MTpjaQ"
        case .instagram: return "<INSTAGRAM_CLIENT_ID>"
        }
    }
    
    /// URL für die Autorisierung, ggf. mit angehängtem Provider-Parameter.
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
    
    /// Definierte Scopes für den jeweiligen Provider.
    var scopes: String {
        switch self {
        case .facebook:  return "public_profile,email"
        case .twitter:   return "tweet.write tweet.read users.read offline.access"
        case .instagram: return "user_profile,user_media"
        }
    }
    
    /// URL-Scheme, muss in Info.plist registriert werden.
    var redirectScheme: String { "crosspostr" }
    
    /// Finaler Redirect-URI, der bei der Provider-Konfiguration verwendet wird.
    var redirectURI: String { "crosspostr://callback" }
    
    /// Client-Secret, in echten Projekten sicher verwahren!
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
