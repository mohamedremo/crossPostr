import Firebase
import SwiftUI

@main
struct crosspostrApp: App {
    @StateObject var authVM: AuthViewModel = AuthViewModel()
    @StateObject var tabVM: TabBarViewModel = TabBarViewModel()
    @StateObject var dashVM: DashboardViewModel = DashboardViewModel()
    @StateObject var createVM: CreateViewModel = CreateViewModel()
    @StateObject var setsVM: SettingsViewModel = SettingsViewModel()
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false

    // MARK: - FIREBASE - Initialisierung
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                MainView(
                    authVM: authVM,
                    tabVM: tabVM,
                    dashVM: dashVM,
                    createVM: createVM,
                    setsVM: setsVM
                )
                .withErrorAlert()
                .onOpenURL(perform: Utils.shared.handleOpenURL)
                .task {
                    if authVM.isLoggedIn {
                        tabVM.loadProfile()
                        await dashVM.fetchAllRemotes()
                        dashVM.getAllPosts()
                    }
                }
            } else {
                OnboardingView(hasOnboarded: $hasOnboarded)
            }
        }
    }
}
