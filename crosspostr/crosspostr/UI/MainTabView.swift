import Foundation
import SwiftUI

struct MainTabView: View {
    @ObservedObject var tabVM: TabBarViewModel
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var postVM: CreateViewModel
    @ObservedObject var dashVM: DashboardViewModel
    @ObservedObject var createVM: CreateViewModel
    @EnvironmentObject var errorManager: ErrorManager

    var body: some View {
        TabBarView(vM: tabVM) {
            switch tabVM.selectedPage {
            case .home:
                DashboardView(viewModel: dashVM, authVM: authVM, createVM: CreateViewModel())
                    .environmentObject(errorManager)
            case .create:
                CreateView(viewModel: postVM)
                    .environmentObject(errorManager)
            case .settings:
                SettingsView(vm: authVM )
                    .environmentObject(errorManager)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
