import Foundation
import SwiftUI

struct MainTabView: View {
    @ObservedObject var tabVM: TabBarViewModel
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var postVM: PostViewModel

    var body: some View {
        TabBarView(vM: tabVM) {
            switch tabVM.selectedPage {
            case .home:
                Button("Logout") { authVM.logout() }
            case .create:
                CreateView(viewModel: postVM)
            case .settings:
                Text("Settings")
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
