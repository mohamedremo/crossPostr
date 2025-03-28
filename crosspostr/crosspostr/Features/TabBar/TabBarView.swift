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
            return "house.fill"
        case .create:
            return "sparkle"
        case .settings:
            return "gearshape.fill"
        }
    }

    var id: Self {
        self
    }
}

struct TabBarView: View {
    @AppStorage("showTabBar") var showTabBar: Bool = true
    @ObservedObject var vM: TabBarViewModel
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var dashVM: DashboardViewModel
    @ObservedObject var createVM: CreateViewModel
    @ObservedObject var setsVM: SettingsViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 5) {
                TopBarView(vM: vM)
                NavigationStack {
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
                                case .create:
                                    CreateView(vM: createVM, setsVM: setsVM)
                                case .settings:
                                    SettingsView(vM: setsVM, authVM: authVM)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.5), value: vM.selectedPage)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottom) {
            Group {
                if showTabBar {
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
            .transition(.move(edge: .bottom))
            .animation(.easeInOut(duration: 0.3), value: showTabBar)
        }
    }
}

struct TabButton: View {
    @ObservedObject var vM: TabBarViewModel
    let tab: TabBarPage
    @State private var pulse = false
    @State private var gradientAngle: Angle = .degrees(0)
    @State private var wiggle = false

    var body: some View {
        ZStack {
            if tab == .create {
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [.pink, .purple, .pink]),
                            center: .center,
                            angle: gradientAngle
                        )
                    )
                    .frame(width: 56, height: 56)
                    .onAppear {
                        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                            gradientAngle = .degrees(360)
                        }
                    }

                Image(systemName: tab.image)
                    .font(.title2)
                    .foregroundColor(.white)
                    .scaleEffect(pulse ? 1.25 : 1.0)
                    .rotationEffect(wiggle ? .degrees(5) : .degrees(0))
                    .animation(wiggle ? .easeInOut(duration: 0.15).repeatCount(6, autoreverses: true) : .default, value: wiggle)
                    .onAppear {
                        pulse = true
                        if vM.selectedPage == .create {
                            wiggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                wiggle = false
                            }
                        }
                    }
            } else {
                Image(systemName: tab.image)
                    .font(.title2)
                    .fontWeight(tab == vM.selectedPage ? .black : .regular)
                    .foregroundStyle(AppTheme.cardGradient)
            }
        }
        .frame(height: 60)
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
