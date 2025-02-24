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
    @Published var isLoading: Bool = false
    @Published var showCreatePostSheet: Bool = false

    private var repo = Repository.shared
    
    func getAllPosts() {
        guard let currentUser = repo.currentUser else {
            return
        }
        self.posts = repo.localRepository.fetchAllPosts(userId: currentUser.uid)
        print("Successfully fetched local posts - \(posts)")
    }
    
    ///essenziell für die darstellung der bilder die im cache zum jeweiligen post gespeichert ist
    func getMediaFilesForPost(_ post: Post) -> [URL] {
        guard let mediaId = post.mediaId else {
            return []
        }
        
        var mediaURLs: [URL] = []
        
        do {
            mediaURLs = try repo.localRepository.getFiles(inFolderWith: mediaId)
        } catch {
            print(error.localizedDescription)
        }
        
        return mediaURLs
    }

    func fetchAllRemotes() async {
        do {
            let remotePosts = try await repo.remoteRepository.getAllPostsRemote()
            print("remote posts fetched \(remotePosts)")
            try remotePosts.forEach { post in
                try repo.localRepository.insert(post.toPost())  // Swift Data save
                print("Saved post: \(post) in Swift Data Local Storage")
            }
            self.getAllPosts()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
