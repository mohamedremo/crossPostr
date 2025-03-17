import Foundation
import SwiftUI

struct MainTabView: View {
    @ObservedObject var tabVM: TabBarViewModel
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var postVM: CreateViewModel
    @ObservedObject var dashVM: DashboardViewModel
    @ObservedObject var createVM: CreateViewModel

    var body: some View {
        TabBarView(vM: tabVM) {
            switch tabVM.selectedPage {
            case .home:
                DashboardView(viewModel: dashVM, authVM: authVM, createVM: CreateViewModel())
                    .environmentObject(ErrorManager.shared)
            case .create:
                CreateView(viewModel: postVM)
                    .environmentObject(ErrorManager.shared)
            case .settings:
                SettingsView(vm: authVM )
                    .environmentObject(ErrorManager.shared)
                
            case .info:
                TwitterLoginView()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
