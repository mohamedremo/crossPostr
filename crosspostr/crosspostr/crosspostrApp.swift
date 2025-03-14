import Firebase
import SwiftUI

@main
struct crosspostrApp: App {
    @StateObject var authVM: AuthViewModel = AuthViewModel()
    @StateObject var tabVM: TabBarViewModel = TabBarViewModel()
    @StateObject var postVM: CreateViewModel = CreateViewModel()
    @StateObject var dashVM: DashboardViewModel = DashboardViewModel()
    @StateObject var createVM: CreateViewModel = CreateViewModel()
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    // MARK: - FIREBASE - Initialisierung
    init() {
        Utils.shared.loadRocketSimConnect()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                ContentView(
                    authVM: authVM,
                    tabVM: tabVM,
                    postVM: postVM,
                    dashVM: dashVM,
                    createVM: createVM
                )
                .onOpenURL(perform: Utils.shared.handleOpenURL) /// Verarbeitet Google, Facebook & Snapchat Logins (Für Access-)
                .task {
                    await dashVM.fetchAllRemotes() // Start
                    dashVM.getAllPosts()
                }
                
            } else {
                OnboardingView(hasOnboarded: $hasOnboarded)
            }
        }
    }
}
