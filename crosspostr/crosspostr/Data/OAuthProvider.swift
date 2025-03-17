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
    
    /// Hier hängen wir `provider=twitter` etc. an die URL an,
    /// damit es später im Callback ausgelesen werden kann.
    var authorizationURL: String {
        switch self {
        case .facebook:
            // Sonderfall Facebook
            return "https://www.facebook.com/v15.0/dialog/oauth"
            
        case .twitter:
            // Twitter mit Query-Param "provider=twitter"
            return "https://twitter.com/i/oauth2/authorize"
            
        case .instagram:
            // Instagram mit Query-Param "provider=instagram"
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
    
    /// Deine Scopes, je nach Plattform
    var scopes: String {
        switch self {
        case .facebook:  return "public_profile,email"
        case .twitter:   return "tweet.write tweet.read offline.access"
        case .instagram: return "user_profile,user_media"
        }
    }
    
    // Muss in Info.plist registriert sein -> URL Types → CFBundleURLSchemes
    var redirectScheme: String { "crosspostr" }
    
    // Der finale Redirect, den du bei Twitter/Instagram usw. eingibst
    var redirectURI: String { "crosspostr://callback" }
    
    // Das Client-Secret je nach Provider
    // Achtung: In echten Projekten nicht hart codieren!
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
