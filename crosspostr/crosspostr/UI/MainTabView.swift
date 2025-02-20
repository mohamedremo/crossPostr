import Foundation
import SwiftUI

struct MainTabView: View {
    @ObservedObject var tabVM: TabBarViewModel
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var postVM: CreateViewModel
    @ObservedObject var dashVM: DashboardViewModel
    @ObservedObject var dashDetailVM: DashboardDetailViewModel

    var body: some View {
        TabBarView(vM: tabVM) {
            switch tabVM.selectedPage {
            case .home:
                DashboardView(viewModel: dashVM, authVM: authVM)
            case .create:
                CreateView(viewModel: postVM)
            case .settings:
                DashboardDetailView(vM: dashDetailVM)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
