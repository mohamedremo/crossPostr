import AuthenticationServices
import CryptoKit
import Foundation
import KeychainAccess
import OAuthSwift
import UIKit

/// OAuthManager steuert den OAuth2-Flow für verschiedene Provider.
class OAuthManager: NSObject {

    static let shared = OAuthManager()
    private let keychainManager = KeychainManager.shared
    var oAuthFlow: OAuth2Swift?
    
    // MARK: - Login
    /// Startet den OAuth2-Login für den angegebenen Provider.
    func login(with provider: OAuthProvider, completion: @escaping (Result<String, Error>) -> Void) {
        // 1. PKCE vorbereiten: Erzeuge Code Verifier und Code Challenge
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)

        // 2. OAuth2Swift-Objekt erstellen
        oAuthFlow = OAuth2Swift(
            consumerKey: provider.clientId,
            consumerSecret: provider.clientSecret,
            authorizeUrl: provider.authorizationURL,
            accessTokenUrl: provider.token,
            responseType: "code"
        )
        oAuthFlow?.allowMissingStateCheck = true

        // 3. URL-Handler für den OAuth-Flow setzen
        if let rootVC = Utils.shared.getRootViewController() {
            oAuthFlow?.authorizeURLHandler = SafariURLHandler(viewController: rootVC, oauthSwift: oAuthFlow!)
        } else {
            oAuthFlow?.authorizeURLHandler = SafariURLHandler(viewController: UIViewController(), oauthSwift: oAuthFlow!)
        }

        // 4. OAuth-Flow starten
        oAuthFlow?.authorize(
            withCallbackURL: provider.redirectURI,
            scope: provider.scopes,
            state: UUID().uuidString,
            codeChallenge: codeChallenge,
            codeChallengeMethod: "S256",
            codeVerifier: codeVerifier
        ) { result in
            switch result {
            case .success(let (credential, _, _)):
                self.handleOAuthSuccess(credential: credential, provider: provider, completion: completion)
            case .failure(let error):
                print("❌ OAuth-Flow fehlgeschlagen für \(provider): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    /// Verarbeitet den erfolgreichen OAuth-Flow, speichert Tokens und gibt das AccessToken zurück.
    private func handleOAuthSuccess(credential: OAuthSwiftCredential, provider: OAuthProvider, completion: @escaping (Result<String, Error>) -> Void) {
        let accessToken = credential.oauthToken
        let refreshToken = credential.oauthRefreshToken
        let expiry = credential.oauthTokenExpiresAt

        print("✅ OAuth-Flow erfolgreich für \(provider)")
        print("Access-Token: \(accessToken)")
        print("Refresh-Token: \(refreshToken)")
        print("Token läuft ab am: \(String(describing: expiry))")

        do {
            // Speichere Access-Token
            try keychainManager.set(accessToken, key: "\(provider)_accessToken")
            print("✅ OAuth Access Token gespeichert: \(accessToken.prefix(5))...")

            // Speichere Refresh-Token, falls vorhanden
            if !refreshToken.isEmpty {
                try keychainManager.set(refreshToken, key: "\(provider)_refreshToken")
                print("✅ Refresh-Token gespeichert")
            } else {
                print("⚠️ Kein Refresh-Token vorhanden")
            }
            
            // Speichere Ablaufdatum, falls vorhanden
            if let expiryDate = expiry {
                try keychainManager.set(String(describing: expiryDate), key: "\(provider)_expiryDate")
            }
            
            // Erfolg zurückgeben
            completion(.success(accessToken))
        } catch {
            print("Fehler beim Speichern in Keychain: \(error)")
            completion(.failure(error))
        }
    }
    
    // MARK: - PKCE Unterstützung
    /// Erzeugt einen zufälligen Code Verifier.
    private func generateCodeVerifier() -> String {
        return UUID().uuidString + UUID().uuidString
    }
    
    /// Erzeugt eine Code Challenge aus dem gegebenen Code Verifier.
    private func generateCodeChallenge(from codeVerifier: String) -> String {
        let data = Data(codeVerifier.utf8)
        let hash = SHA256.hash(data: data)
        var codeChallenge = Data(hash).base64EncodedString()
        codeChallenge = codeChallenge
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return codeChallenge
    }
    
    // MARK: - Spezielles Twitter-Login
    /// Startet den OAuth2-Login speziell für Twitter.
    func loginTwitter(completion: @escaping (Result<String, Error>) -> Void) {
        login(with: .twitter, completion: completion)
    }
    
    // MARK: - Callback Handling
    /// Behandelt die Callback-URL nach Abschluss des OAuth-Flow.
    func handleOpenURL(_ url: URL) {
        OAuth2Swift.handle(url: url)
    }

    // MARK: - Token abrufen
    /// Ruft das gespeicherte Access-Token für den angegebenen Provider ab.
    func token(for provider: OAuthProvider) -> String? {
        return try? keychainManager.getString("\(provider)_accessToken")
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension OAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return UIWindow()
        }
        return window
    }
}
