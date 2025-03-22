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

    private let oauthManager = OAuthManager.shared

    func post(post: Post, to provider: OAuthProvider) async throws {
        // 1) Token checken
        guard let token = oauthManager.token(for: provider) else {
            throw SocialError.noToken
        }

        // 2) Je nach provider den passenden Endpoint callen:
        switch provider {
        case .twitter:
            try await postTweet(token: token, post: post)
        case .facebook:
            try await postToFacebook(token: token, post: post)
        case .instagram:
            try await postToInstagram(token: token, post: post)
        }
    }

    private func postTweet(token: String, post: Post) async throws {
        // 1. URL erstellen
        guard let url = URL(string: "https://api.twitter.com/2/tweets") else {
            print("❌ Ungültige URL")
            throw SocialError.invalidURL
        }
        print("Starte tweet post mit token \(token) und post \(post.content)")

        // 2. JSON-Body mit Text
        let body: [String: Any] = [
            "text": post.content
        ]

        // 3. Body in JSON-Daten umwandeln
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("❌ Konnte Body nicht serialisieren")
            throw SocialError.invalidResponse
        }

        // 4. Request vorbereiten
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print(request.url?.absoluteString)

        // 5. Request senden
        let (data, response) = try await URLSession.shared.data(for: request)

        // 6. Response überprüfen
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Keine gültige HTTP-Antwort erhalten")
            throw SocialError.invalidResponse
        }

        print("📡 Status Code: \(httpResponse.statusCode)")
        print("📎 Header: \(httpResponse.allHeaderFields)")

        // Erfolgreiche Statuscodes: 200 (OK) oder 201 (Created)
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = String(data: data, encoding: .utf8) ?? "Keine Antwort"
            print("❌ Fehler: Status \(httpResponse.statusCode) – \(errorResponse)")
            throw SocialError.serverError(httpResponse.statusCode)
        }

        // Erfolgreiche JSON-Antwort
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            print("✅ Antwort: \(json)")
        } else {
            print("✅ Status \(httpResponse.statusCode), aber JSON konnte nicht geparst werden.")
        }
    }

    private func postToFacebook(token: String, post: Post) async throws {
        // analog: Graph API
    }

    private func postToInstagram(token: String, post: Post) async throws {
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
