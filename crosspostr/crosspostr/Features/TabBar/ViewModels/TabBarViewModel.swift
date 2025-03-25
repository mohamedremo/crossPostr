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

    var profile: Profile? {
        return repo.mainProfile
    }
}
