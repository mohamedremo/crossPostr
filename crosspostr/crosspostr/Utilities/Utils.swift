//
//  Utils.swift
//  crosspostr
//
//  Description: Provides reusable utility functions for UI handling, keyboard control, image loading and OAuth redirect parsing.
//  Author: Mohamed Remo
//  Created on: [Datum einfügen]
//

import SwiftUI
import SCSDKLoginKit
import GoogleSignIn
import OAuthSwift

/// Shared utility class with common helper functions for UI and OAuth integration.
class Utils {
    static let shared: Utils = Utils()

    private init() {}
    
    // MARK: - UI Helpers

    /// Returns the current root view controller from the active window scene.
    func getRootViewController() -> UIViewController? {
        guard
            let scene = UIApplication.shared.connectedScenes.first
                as? UIWindowScene,
            let rootViewController = scene.windows.first?.rootViewController
        else {
            return nil
        }
        return getVisibleViewController(from: rootViewController)
    }

    /// Traverses navigation/tab/presented controller stack to return the top-most visible view controller.
    ///
    /// - Parameter vc: The starting view controller to search from.
    /// - Returns: The most visible `UIViewController` instance.
    func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        if let nav = vc as? UINavigationController {
            return getVisibleViewController(from: nav.visibleViewController!)
        }
        if let tab = vc as? UITabBarController {
            return getVisibleViewController(from: tab.selectedViewController!)
        }
        if let presented = vc.presentedViewController {
            return getVisibleViewController(from: presented)
        }
        return vc
    }

    /// Forces dismissal of the keyboard by resigning first responder.
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
            for: nil)
    }

    /// Loads a `UIImage` from a local file path.
    ///
    /// - Parameter path: Local file path.
    /// - Returns: The loaded image or `nil` if loading fails.
    func loadUIImage(from path: String) -> UIImage? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    // MARK: - OAuth Redirect Handling (Google als Basis, Facebook optional, Snapchat für Creative Kit)
    
    /// Extracts access token from Facebook login redirect URL and stores it in UserDefaults.
    ///
    /// - Parameter url: The redirect URL from Facebook.
    func handleFacebookLogin(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let fragment = components.fragment else {
            print("❌ Fehler: Keine Facebook-Daten in URL gefunden")
            return
        }
        
        let params = fragment.split(separator: "&").reduce(into: [String: String]()) { result, item in
            let parts = item.split(separator: "=")
            if parts.count == 2 {
                let key = String(parts[0])
                let value = String(parts[1])
                result[key] = value
            }
        }
        
        if let accessToken = params["access_token"] {
            print("✅ Facebook Access Token erhalten: \(accessToken)")
            
            // 🔥 Nur Access Token speichern
            UserDefaults.standard.set(accessToken, forKey: "facebook_access_token")
            UserDefaults.standard.synchronize()
            print("🔗 Facebook Access Token wurde gespeichert!")
        } else {
            print("❌ Kein Facebook Access Token gefunden!")
        }
    }
    
    /// Universal OAuth callback handler that routes URLs to the correct service (Google, Facebook, Snapchat, Twitter).
    ///
    /// - Parameter url: The callback URL passed from the system.
    func handleOpenURL(url: URL) {
        let urlString = url.absoluteString
        
        if urlString.contains("fb501664873040786://auth") {
            handleFacebookLogin(url: url) ///Facebook
        } else if urlString.contains("crosspostr://callback") {
            // Twitter OAuthFlow Rückruf
            OAuthSwift.handle(url: url)
        } else if urlString.contains("snapkit") {
            SCSDKLoginClient.application(UIApplication.shared, open: url, options: [:]) ///Snapchat
        } else {
            GIDSignIn.sharedInstance.handle(url) /// Google OAuth Haupt-Login
        }
    }
}
