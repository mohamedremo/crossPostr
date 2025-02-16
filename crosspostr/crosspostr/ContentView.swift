import SwiftUI
import GoogleSignIn
import Foundation

struct ContentView: View {
    @ObservedObject var authVM: AuthViewModel = AuthViewModel()
    @ObservedObject var tabVM: TabBarViewModel = TabBarViewModel()
    @ObservedObject var postVM: PostViewModel = PostViewModel()
    
    var body: some View {
        if authVM.isLoggedIn {
            MainTabView(tabVM: tabVM, authVM: authVM, postVM: postVM)
        } else {
            OnBoardingScreen(authVM: authVM)
        }
    }
}
