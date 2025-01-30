import Foundation
//
//  TabBarView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//
import SwiftUI

enum TabBarPage: CaseIterable, Identifiable {
    case home
    case create
    case analytics

    var label: String {
        switch self {
        case .home:
            return "Home"
        case .create:
            return "Create"
        case .analytics:
            return "Analytics"
        }
    }

    var image: String {
        switch self {
        case .home:
            return "house"
        case .create:
            return "plus.circle"
        case .analytics:
            return "chart.pie"
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
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            HStack(spacing: 40) {
                ForEach(TabBarPage.allCases) { tab in
                    TabButton(vM: vM, tab: tab)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Material.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.horizontal)
            .padding(.bottom, 1)
            .shadow(color: .black.opacity(0.2), radius: 5, y: 5)
        }
    }
}

struct TabButton: View {
    @ObservedObject var vM: TabBarViewModel
    let tab: TabBarPage

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: vM.checkTab(tab) ? tab.image.appending(".fill") : tab.image)
                .font(vM.checkTab(tab) ? .title : .title2)
                .fontWeight(vM.checkTab(tab) ? .bold : .regular)
                .foregroundStyle(AppTheme.dipsetPurple)
            Text(tab.label)
                .font(vM.checkTab(tab) ? .caption : .caption2)
                .fontWeight(vM.checkTab(tab) ? .medium : .ultraLight)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            withAnimation(.easeInOut) {
                vM.selectedPage = tab
            }
        }
    }
}

class TabBarViewModel: ObservableObject {
    @Published var selectedPage: TabBarPage = .home
    
    func checkTab(_ actualTab: TabBarPage) -> Bool {
        return actualTab == selectedPage
    }
}

#Preview {
    @Previewable @StateObject var vM = TabBarViewModel()
    @Previewable @State var authVM: AuthViewModel = AuthViewModel()
    TabBarView(vM: vM) {
        switch vM.selectedPage {
        case .home: LoginScreen(vM: authVM)
        case .create: Text("Create")
        case .analytics: OnBoardingScreen()
        }
    }
}
