//
//  SocialManager.swift
//  crosspostr
//
//  Description: Handles the posting logic to external social media platforms like Twitter, Facebook, and Instagram.
//  Author: Mohamed Remo
//  Created on: 09.03.2025
//
import Foundation

/// Central manager for posting content to supported social media providers. Uses stored OAuth tokens and dispatches to platform-specific APIs.
@MainActor
class SocialManager {
    static let shared = SocialManager()

    private init() {}

    private let oauthManager = OAuthManager.shared
    private let errorManager = ErrorManager.shared

    /**
     Dispatches a given post to the specified social media provider.

     - Parameters:
       - post: The post to be published.
       - provider: The target social media provider.
     - Throws: `SocialError` if token is missing, URL is invalid, or the API returns an error.
     */
    func post(post: Post, to provider: OAuthProvider) async throws {
        // 1) Token checken
        guard let token = oauthManager.token(for: provider) else {
            throw SocialError.noToken
        }

        // 2) Je nach provider den passenden Endpoint callen:
        do {
            switch provider {
            case .twitter:
                try postTweet(token: token, post: post)
            case .facebook:
                try postToFacebook(token: token, post: post)
            case .instagram:
                try postToInstagram(token: token, post: post)
            }
        } catch {
            errorManager.setError(error)
        }
    }

    /**
     Posts the given content as a tweet using the Twitter API v2.

     - Parameters:
       - token: The OAuth access token for Twitter.
       - post: The content to be posted.
     - Throws: `SocialError` if the request fails or returns an error status.
     */
    private func postTweet(token: String, post: Post) throws {
        Task {
            let request = try makeTwitterRequest(token: token, post: post)
            let (data, response) = try await URLSession.shared.data(
                for: request)
            try handleResponse(data: data, response: response)
        }
    }

    private func makeTwitterRequest(token: String, post: Post) throws -> URLRequest {
        guard let url = URL(string: "https://api.twitter.com/2/tweets") else {
            throw SocialError.invalidURL
        }

        let body = ["text": post.content]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body)
        else {
            throw SocialError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        return request
    }

    private func handleResponse(data: Data, response: URLResponse) throws {
        do {
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SocialError.invalidResponse
            }

            print("📡 Status Code: \(httpResponse.statusCode)")
            print("📎 Header: \(httpResponse.allHeaderFields)")

            guard (200...299).contains(httpResponse.statusCode) else {
                let errorResponse =
                    String(data: data, encoding: .utf8) ?? "Keine Antwort"
                print(
                    "❌ Fehler: Status \(httpResponse.statusCode) – \(errorResponse)"
                )
                throw SocialError.serverError(httpResponse.statusCode)
            }

            if let json = try? JSONSerialization.jsonObject(
                with: data, options: [])
            {
                print("✅ Antwort: \(json)")
            } else {
                print(
                    "✅ Status \(httpResponse.statusCode), aber JSON konnte nicht geparst werden."
                )
            }
        } catch {
            errorManager.setError(error)
        }
    }

    private func postToFacebook(token: String, post: Post) throws {
        // analog: Graph API
    }

    private func postToInstagram(token: String, post: Post) throws {
        // analog: Instagram Graph API
    }
}

/// Represents errors that may occur during social media posting via `SocialManager`.
enum SocialError: Error {
    case noToken
    case invalidURL
    case invalidResponse
    case serverError(Int)
}
