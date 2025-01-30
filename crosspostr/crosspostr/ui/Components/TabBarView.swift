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
            Image(systemName: tab.image)
                .font(.title3)
                .fontWeight(tab == vM.selectedPage ? .bold : .regular)
                .foregroundStyle(AppTheme.blueGradient)
            Text(tab.label)
                .font(.footnote)
        }
        .onTapGesture {
            withAnimation(.easeInOut){
                vM.selectedPage = tab
            }
        }
    }
}

class TabBarViewModel: ObservableObject {
    @Published var selectedPage: TabBarPage = .home
}

#Preview {
    @Previewable @StateObject var vM = TabBarViewModel()
    TabBarView(vM: vM) {
        switch vM.selectedPage {
        case .home: Text("home")
        case .create: Text("Create")
        case .settings: Text("Settings")
        }
    }
}
