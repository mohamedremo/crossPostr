//
//  Untitled.swift
//  crosspostr
//
//  Created by Mohamed Remo on 17.02.25.
//
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var posts: [Post] = []

    private var repo = Repository.shared

    var gradient = EllipticalGradient(
        stops: [
            Gradient.Stop(
                color: Color(red: 0.7, green: 0.47, blue: 0.87),
                location: 0.00),
            Gradient.Stop(
                color: Color(red: 0.8, green: 0.35, blue: 0.33)
                    .opacity(0.08), location: 0.77),
            Gradient.Stop(
                color: Color(red: 0.7, green: 0.47, blue: 0.87),
                location: 1.00),
        ],
        center: UnitPoint(x: 0.15, y: 0.21)
    )

    func getAllPosts() {
        guard let currentUser = repo.currentUser else {
            return
        }
        self.posts = repo.localRepository.fetchAllPosts(userId: currentUser.uid)
    }

    func fetchAllRemotes() async {
        do {
            let remotePosts = try await repo.remoteRepository.getAllPostsRemote()
            try remotePosts.forEach { post in
                try repo.localRepository.insert(post.toPost())  // Swift Data save
            }
            self.getAllPosts()
        } catch {
            print(error.localizedDescription)
        }
    }
}
