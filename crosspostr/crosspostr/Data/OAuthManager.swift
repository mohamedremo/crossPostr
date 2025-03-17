import AuthenticationServices
import CryptoKit
import Foundation
import KeychainAccess
import OAuthSwift
//
//  OAuthManager.swift
//  crosspostr
//
//  Created by Mohamed Remo on 09.03.25.
//
import UIKit

/// Apple nutzt intern Objective-C -> wir brauchen NSObject
class OAuthManager: NSObject {

    static let shared = OAuthManager()
    var oAuthFlow: OAuth2Swift?

    // MARK: - Login-Methode
    func login(
        with provider: OAuthProvider,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        // 1) PKCE vorbereiten (Für die Sicherheit schützt den FLOW)
        // PKCE: Wir generieren einen Code Verifier und leiten daraus den Code Challenge ab.
        let codeVerifier = UUID().uuidString + UUID().uuidString
        let data = Data(codeVerifier.utf8)
        let hash = SHA256.hash(data: data)

        var codeChallenge = Data(hash).base64EncodedString()
        codeChallenge =
            codeChallenge
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        // 2) OAuthSwift-Objekt erstellen
        oAuthFlow = OAuth2Swift(
            consumerKey: provider.clientId,
            consumerSecret: provider.clientSecret,
            authorizeUrl: provider.authorizationURL,
            accessTokenUrl: provider.token,
            responseType: "code"
        )

        oAuthFlow?.allowMissingStateCheck = true

        // 3) Session-Präsentation (ASWebAuthenticationSession)
        //    => ohne das würde iOS nicht wissen, wo der Flow angezeigt wird
        oAuthFlow!.authorizeURLHandler = SafariURLHandler(
            viewController: Utils.shared.getRootViewController()
                ?? UIViewController(),
            oauthSwift: oAuthFlow!)

        // 4) Den Flow starten
        //    Hier achten wir darauf, dass der Callback mit "crosspostr://callback" übereinstimmt
        oAuthFlow?.authorize(
            withCallbackURL: provider.redirectURI,  // e.g. crosspostr://callback
            scope: provider.scopes,  // "tweet.write tweet.read offline.access"
            state: UUID().uuidString,  // random state
            codeChallenge: codeChallenge,
            codeChallengeMethod: "S256",
            codeVerifier: codeVerifier
        ) { result in
            switch result {
            case .success(let (credential, _, _)):
                print("✅ OAuth-Flow erfolgreich für \(provider)")
                let accessToken = credential.oauthToken
                let refreshToken = credential.oauthRefreshToken
                let expiry = credential.oauthTokenExpiresAt

                print("Access-Token: \(accessToken)")
                print("Refresh-Token: \(refreshToken)")
                print("Token läuft ab am: \(String(describing: expiry))")

                // 5) KeychainAccess zum Speichern verwenden
                let keychain = Keychain(service: "com.crosspostr.oauth")
                do {
                    try keychain.set(
                        accessToken, key: "\(provider)_accessToken")
                    try keychain.set(
                        refreshToken, key: "\(provider)_refreshToken")
                    if let expiryDate = expiry {
                        // willst du das Ablaufdatum speichern? Dann (z.B.) so:
                        try keychain.set(
                            String(describing: expiryDate),
                            key: "\(provider)_expiryDate")
                    }
                } catch {
                    print("Fehler beim Speichern in Keychain: \(error)")
                }

                // Erfolg an den Aufrufer weitergeben
                completion(.success(accessToken))

            case .failure(let error):
                print(
                    "❌ OAuth-Flow fehlgeschlagen für \(provider): \(error.localizedDescription)"
                )
                completion(.failure(error))
            }
        }
    }

    // MARK: - Spezielles Login für Twitter
    func loginTwitter(completion: @escaping (Result<String, Error>) -> Void) {
        login(with: .twitter, completion: completion)
    }

    // MARK: - Handle Callback aus crosspostrApp
    func handleOpenURL(_ url: URL) {
        // hier wertet OAuthSwift den Token-Code aus
        OAuth2Swift.handle(url: url)
    }

    // MARK: - Token abrufen
    func token(for provider: OAuthProvider) -> String? {
        // Entweder: Dictionary
        // return storedTokens[provider]

        // Oder: direkt aus Keychain (empfohlen)
        let keychain = Keychain(service: "com.crosspostr.oauth")
        return try? keychain.getString("\(provider)_accessToken")
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension OAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession)
        -> ASPresentationAnchor
    {
        guard
            let windowScene = UIApplication
                .shared
                .connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return UIWindow()
        }
        return window
    }
}
