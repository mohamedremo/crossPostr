//
//  ErrorManager.swift
//  crosspostr
//
//  Description: Centralized error handling and distribution via ObservableObject for use in SwiftUI views.
//  Author: Mohamed Remo
//  Created on: 22.03.2025
//

import Foundation
import SwiftUI

/// A simple wrapper to represent error messages with an identifiable ID, for use in SwiftUI bindings.
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

enum AppError: LocalizedError {
    case noUser
    case unknown
    case postTextTooShort
    case postTextEmpty

    var errorDescription: String? {
        switch self {
        case .noUser:
            return "Kein Benutzer angemeldet."
        case .unknown:
            return "Ein unbekannter Fehler ist aufgetreten."
        case .postTextTooShort:
            return "Der Post-Text muss mindestens 5 Zeichen lang sein."
        case .postTextEmpty:
            return "Der Post-Text darf nicht leer sein. "
        }
    }
}

enum AuthError: LocalizedError {
    case invalidEmail
    case emptyPassword
    case passwordMismatch
    case passwordTooShort
    case unknown(String)
    case noRootViewController
    case missingIDToken
   
    

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Die E-Mail-Adresse ist ungültig."
        case .emptyPassword:
            return "Das Passwort darf nicht leer sein."
        case .passwordMismatch:
            return "Die Passwörter stimmen nicht überein."
        case .passwordTooShort:
            return "Das Passwort muss mindestens 6 Zeichen lang sein."
        case .unknown(let message):
            return message
        case .noRootViewController:
            return "Es konnte kein RootViewController gefunden werden."
        case .missingIDToken:
            return "Der ID-Token wurde nicht gefunden."
        
        }
    }
}


/// Singleton class that provides centralized error publishing for SwiftUI UI presentation and logging.
/// Allows setting and clearing of the current error with automatic observable updates.
@MainActor
class ErrorManager: ObservableObject {
    
    static let shared = ErrorManager()
    
    @Published var currentError: ErrorWrapper? = nil
    
    private init() {}

    /**
     Publishes a new error by wrapping it in an `ErrorWrapper` and assigning it to the published property.

     - Parameter error: The `Error` instance to be published.
     */
    func setError(_ error: Error) {
        print(error.localizedDescription)
        self.currentError = ErrorWrapper(message: error.localizedDescription)
    }
    
    /// Clears the current error and resets the error state.
    func clearError() {
        self.currentError = nil
    }
}

struct GlobalErrorAlertModifier: ViewModifier {
    @ObservedObject private var errorManager = ErrorManager.shared

    func body(content: Content) -> some View {
        content.alert(item: $errorManager.currentError) { error in
            Alert(
                title: Text("Fehler"),
                message: Text(error.message),
                dismissButton: .default(Text("OK")) {
                    errorManager.clearError()
                }
            )
        }
    }
}

extension View {
    func withErrorAlert() -> some View {
        self.modifier(GlobalErrorAlertModifier())
    }
}
