import Firebase
import GoogleSignIn
import SwiftData
import SwiftUI
import SCSDKLoginKit

@main
struct crosspostrApp: App {
    @StateObject var authVM: AuthViewModel = AuthViewModel()
    @StateObject var tabVM: TabBarViewModel = TabBarViewModel()
    @StateObject var postVM: CreateViewModel = CreateViewModel()
    @StateObject var dashVM: DashboardViewModel = DashboardViewModel()
    @StateObject var createVM: CreateViewModel = CreateViewModel()
    @StateObject var errorManager = ErrorManager.shared
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    init() {
        loadRocketSimConnect()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                ContentView(authVM: authVM,tabVM: tabVM,postVM: postVM, dashVM: dashVM,createVM: createVM)
                .onOpenURL(perform: handleOpenURL) /// Verarbeitet Google, Facebook & Snapchat Logins (Für Access-
                .environmentObject(errorManager)
                .task {
                    await dashVM.fetchAllRemotes() /// Zum Start Remotes fetchen
                    dashVM.getAllPosts()
                }
            } else {
                OnboardingView(hasOnboarded: $hasOnboarded)
            }
        }
    }
    
    // MARK: - OAuth Redirect Handling (Google als Basis, Facebook optional, Snapchat für Creative Kit)
    func handleOpenURL(url: URL) {
        let urlString = url.absoluteString
        
        if urlString.contains("fb501664873040786://auth") {
            handleFacebookLogin(url: url) ///Facebook
        } else if urlString.contains("snapkit") {
            SCSDKLoginClient.application(UIApplication.shared, open: url, options: [:]) ///Snapchat
        } else {
            GIDSignIn.sharedInstance.handle(url) /// Google OAuth Haupt-Login
        }
    }
    
    // MARK: Facebook mit Google-Konto verknüpfen (Nur Access Token speichern)
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
    
    // Load RocketSim framework for Network Monitoring, print error if it fails.
    func loadRocketSimConnect() {
        #if DEBUG
        guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
            print("Failed to load linker framework")
            return
        }
        print("RocketSim Connect successfully linked")
        #endif
    }
}
