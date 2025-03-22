import Foundation
import SwiftUI

struct MainTabView: View {
    @ObservedObject var tabVM: TabBarViewModel
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var dashVM: DashboardViewModel
    @ObservedObject var createVM: CreateViewModel
    @ObservedObject var setsVM: SettingsViewModel

    var body: some View {
        TabBarView(vM: tabVM) {
            switch tabVM.selectedPage {
            case .home:
                DashboardView(viewModel: dashVM, authVM: authVM, createVM: CreateViewModel())
                    .environmentObject(ErrorManager.shared)
            case .create:
                CreateView(viewModel: createVM)
                    .environmentObject(ErrorManager.shared)
            case .settings:
                SettingsView(vM: setsVM )
                    .environmentObject(ErrorManager.shared)
                
            case .info:
                Text("Coming Soon")
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
