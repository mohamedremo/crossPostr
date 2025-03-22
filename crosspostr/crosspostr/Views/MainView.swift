import SwiftUI
import GoogleSignIn
import Foundation

struct MainView: View {
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var tabVM: TabBarViewModel
    @ObservedObject var dashVM: DashboardViewModel
    @ObservedObject var createVM: CreateViewModel
    @ObservedObject var setsVM: SettingsViewModel
    
    var body: some View {
        if authVM.isLoggedIn {
            MainTabView(
                tabVM: tabVM,
                authVM: authVM,
                dashVM: dashVM,
                createVM: createVM,
                setsVM: setsVM
            )
            .environmentObject(ErrorManager.shared)
        } else {
            WelcomeScreen(authVM: authVM)
                .environmentObject(ErrorManager.shared)
        }
    }
}
