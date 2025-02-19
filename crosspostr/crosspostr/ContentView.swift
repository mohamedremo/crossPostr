import SwiftUI
import GoogleSignIn
import Foundation

struct ContentView: View {
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var tabVM: TabBarViewModel
    @ObservedObject var postVM: PostViewModel
    @ObservedObject var dashVM: DashboardViewModel
    
    var body: some View {
        if authVM.isLoggedIn {
            MainTabView(tabVM: tabVM, authVM: authVM, postVM: postVM, dashVM: dashVM)
        } else {
            OnBoardingScreen(authVM: authVM)
        }
    }
}
