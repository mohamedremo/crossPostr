import Foundation
import SwiftUI

enum TabBarPage: CaseIterable, Identifiable {
    case home
    case create
    case settings


    var label: String {
        switch self {
        case .home:
            return "Home"
        case .create:
            return "Create"
        case .settings:
            return "Settings"
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
        }
    }

    var id: Self {
        self
    }
}

struct TabBarView: View {
    @ObservedObject var vM: TabBarViewModel
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var dashVM: DashboardViewModel
    @ObservedObject var createVM: CreateViewModel
    @ObservedObject var setsVM: SettingsViewModel

    var body: some View {
        VStack {
            TopBarView(vM: vM)
            TabView(selection: $vM.selectedPage) {
                ForEach(TabBarPage.allCases) { tab in
                    Group {
                        switch tab {
                        case .home:
                            DashboardView(
                                viewModel: dashVM,
                                authVM: authVM,
                                createVM: createVM,
                                setsVM: setsVM,
                                tabVM: vM
                            )
                            .environmentObject(ErrorManager.shared)
                        case .create:
                            CreateView(vM: createVM, setsVM: setsVM)
                        case .settings:
                            SettingsView(vM: setsVM, authVM: authVM)
                        }
                    }
                    .tag(tab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: vM.selectedPage)
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
                .foregroundStyle(AppTheme.cardGradient)

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

//#Preview {
//    @Previewable @StateObject var vM = TabBarViewModel()
//    TabBarView(vM: vM) {}
//}
