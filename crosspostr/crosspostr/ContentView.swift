import SwiftUI
import GoogleSignIn
import Foundation

struct ContentView: View {
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var tabVM: TabBarViewModel
    @ObservedObject var postVM: CreateViewModel
    @ObservedObject var dashVM: DashboardViewModel
    @ObservedObject var dashDetailVM: DashboardDetailViewModel
    
    var body: some View {
        if authVM.isLoggedIn {
            MainTabView(
                tabVM: tabVM,
                authVM: authVM,
                postVM: postVM,
                dashVM: dashVM,
                dashDetailVM: dashDetailVM
            )
        } else {
            OnBoardingScreen(authVM: authVM)
        }
    }
}
