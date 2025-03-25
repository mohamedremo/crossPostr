import Foundation
import SwiftUI

struct MainTabView: View {
    @ObservedObject var tabVM: TabBarViewModel
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var dashVM: DashboardViewModel
    @ObservedObject var createVM: CreateViewModel
    @ObservedObject var setsVM: SettingsViewModel

    var body: some View {
        TabBarView(
            vM: tabVM,
            authVM: authVM,
            dashVM: dashVM,
            createVM: createVM,
            setsVM: setsVM
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
