//
//  TabBarViewModel.swift
//  crosspostr
//
//  Created by Mohamed Remo on 18.03.25.
//
import Foundation

@MainActor
class TabBarViewModel: ObservableObject {
    private let repo = Repository.shared
    @Published var selectedPage: TabBarPage = .home
    @Published var isTransitioning: Bool = false

    enum PageDirection {
        case forward, backward
    }
    @Published var pageTransitionDirection: PageDirection = .forward

    @Published var profile: Profile?

    func loadProfile() {
        if let main = repo.mainProfile {
            profile = main
            print("🔄 Profil aus Repository geladen: \(main.fullName)")
        } else if let local = repo.localRepository.getProfileObjectLocal() {
            profile = local
            print("💾 Lokales Profil geladen: \(local.fullName)")
        } else {
            print("⚠️ Kein Profil gefunden")
        }
    }
}
