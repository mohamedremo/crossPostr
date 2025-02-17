import Firebase
import GoogleSignIn
import SwiftData
import SwiftUI

@main
struct crosspostrApp: App {
    @StateObject var authVM: AuthViewModel = AuthViewModel()
    @StateObject var tabVM: TabBarViewModel = TabBarViewModel()
    @StateObject var postVM: PostViewModel = PostViewModel()

    // MARK: - FIREBASE - Initialisierung
    init() {
        loadRocketSimConnect()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(authVM: authVM, tabVM: tabVM, postVM: postVM)
                .onOpenURL(perform: handleOpenURL) /// For Google OAuth
        }
    }
    
    //For Google OAuth Auth Flow
    func handleOpenURL(url: URL) {
        GIDSignIn.sharedInstance.handle(url)
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
