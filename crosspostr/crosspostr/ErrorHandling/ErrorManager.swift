import Foundation

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

@MainActor
class ErrorManager: ObservableObject {
    
    static let shared = ErrorManager()
    
    @Published var currentError: ErrorWrapper? = nil
    
    private init() {}

    func setError(_ error: Error) {
        print(error.localizedDescription)
        self.currentError = ErrorWrapper(message: error.localizedDescription)
    }
    
    func clearError() {
        self.currentError = nil
    }
}
