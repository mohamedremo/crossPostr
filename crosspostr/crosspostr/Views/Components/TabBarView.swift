import Foundation
import SwiftUI

enum TabBarPage: CaseIterable, Identifiable {
    case home
    case create
    case settings
    case info

    var label: String {
        switch self {
        case .home:
            return "Home"
        case .create:
            return "Create"
        case .settings:
            return "Settings"
        case .info:
            return "Info"
        }
    }

    var image: String {
        switch self {
        case .home:
            return "house"
        case .create:
            return "plus.circle"
        case .settings:
            return "gear"
        case .info:
            return "info.circle"
        }
    }

    var id: Self {
        self
    }
}

struct TabBarView<Content: View>: View {
    @ObservedObject var vM: TabBarViewModel
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack {
            ZStack {
                AppTheme.mainBackground.ignoresSafeArea() ///App-Hintergrund
                FloatingParticlesView()
                content()
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottom) {
            HStack(spacing: 40) {
                ForEach(TabBarPage.allCases) { tab in
                    TabButton(vM: vM, tab: tab)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, minHeight: 70, maxHeight: 70)
            .background(Material.ultraThinMaterial)
            .cornerRadius(30)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
            .animation(.easeInOut(duration: 0.3), value: vM.selectedPage)
        }
    }
}

struct TabButton: View {
    @ObservedObject var vM: TabBarViewModel
    let tab: TabBarPage

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: tab.image)
                .font(.title3)
                .fontWeight(tab == vM.selectedPage ? .black : .regular)
                .foregroundStyle(AppTheme.mainBackground)

            Text(tab.label)
                .font(.caption)
                .opacity(tab == vM.selectedPage ? 1.0 : 0.8)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity, minHeight: 70, maxHeight: 70)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                vM.selectedPage = tab
            }
        }
    }
}



#Preview {
    @Previewable @StateObject var vM = TabBarViewModel()
    @Previewable @StateObject var dashboardVM = DashboardViewModel()
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var createVM: CreateViewModel = CreateViewModel()
    @Previewable @StateObject var errorHandler = ErrorManager.shared
    TabBarView(vM: vM) {
        switch vM.selectedPage {
        case .home: DashboardView(viewModel: dashboardVM, authVM: authVM,createVM: createVM)
                .environmentObject(errorHandler)
        case .create: Text("Create")
        case .settings: Text("Settings")
        case .info: Text("Info")
        }
    }
}
