//
//  ErrorManager.swift
//  crosspostr
//
//  Created by Mohamed Remo on 23.02.25.
//
import Foundation

@MainActor
class ErrorManager: ObservableObject {
    
    static let shared = ErrorManager()
    
    @Published var currentError: String? = nil
    
    private init() {}

    func setError(_ error: Error) {
        self.currentError = error.localizedDescription
    }
    
    func clearError() {
        self.currentError = nil
    }
}
