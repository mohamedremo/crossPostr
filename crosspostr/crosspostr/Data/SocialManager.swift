//
//  SocialManager.swift
//  crosspostr
//
//  Created by Mohamed Remo on 09.03.25.
//
import Foundation

class SocialManager {
    static let shared = SocialManager()
    private init() {}

    /// Referenz auf den OAuthManager, um an die Tokens zu kommen
    private let oauthManager = OAuthManager.shared
    
    /// Beispiel: Falls du einen Post-Request an Twitter/FB schickst,
    /// könntest du hier auch eine "SocialRemoteRepository" anlegen.
    /// Oder du rufst direkt in `OAuthManager` an, je nach Geschmack.

    func post(content: Post, to provider: OAuthProvider) async throws {
        // 1) Token checken
        guard let token = oauthManager.token(for: provider) else {
            throw SocialError.noToken
        }

        // 2) Je nach provider den passenden Endpoint callen:
        switch provider {
        case .twitter:
            try await postToTwitter(token: token, content: content)
        case .facebook:
            try await postToFacebook(token: token, content: content)
        case .instagram:
            try await postToInstagram(token: token, content: content)
        }
    }

    /// Erzeugt einen URLRequest mit den nötigen Headern für JSON + Bearer-Token.
    private func makeRequest(method: String, urlString: String, token: String) throws -> URLRequest {
        guard let url = URL(string: urlString) else {
            throw SocialError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        // JSON-Header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Bearer-Token
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func postToTwitter(token: String, content: Post) async throws {
        // 1. Request erstellen
        var request = try makeRequest(
            method: "POST",
            urlString: "https://api.twitter.com/2/tweets",
            token: token
        )

        // 2. JSON-Body für den Tweet
        let body = ["text": content.content]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        // 3. Request ausführen
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SocialError.invalidResponse
        }

        // 4. Statuscode auswerten
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
            let errorResponse = String(data: data, encoding: .utf8)
            print("Fehler: Twitter-Status \(httpResponse.statusCode) - \(errorResponse ?? "Keine Antwort")")
            throw SocialError.serverError(httpResponse.statusCode)
        }

        print("Tweet erfolgreich gesendet!")
    }

    private func postToFacebook(token: String, content: Post) async throws {
        // analog: Graph API
    }

    private func postToInstagram(token: String, content: Post) async throws {
        // analog: Instagram Graph API
    }
}

/// Error für SocialManager
enum SocialError: Error {
    case noToken
    case invalidURL
    case invalidResponse
    case serverError(Int)
}
