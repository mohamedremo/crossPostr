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
    
    //MARK: - LOCAL FUNCTIONS (Swift Data & File Manager)
    
    func getAllPosts() {
        guard let currentUser = repo.currentUser else {
            return
        }
        self.posts = repo.localRepository.fetchAllPosts(userId: currentUser.uid)
        print("Successfully fetched local posts - \(posts)")
    }
    
    func delete(this post: Post) async {
        guard let mediaId = post.mediaId else {
            print("Post hat keine Medien Löschvorgang nicht ausführen ")
            return
        }
        do {
            try repo.localRepository.deleteAllFiles(for: mediaId)
            try await repo.remoteRepository.deleteMediaRemote(mediaId: mediaId)
            try await repo.remoteRepository.deletePostRemote(postId: post.id)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    ///essenziell für die darstellung der bilder und videos die im cache zum jeweiligen post gespeichert ist
    func getMediaFilesForPost(_ post: Post) -> [URL] {
        guard let mediaId = post.mediaId else {
            return []
        }
        
        var mediaURLs: [URL] = []
        
        do {
            mediaURLs = try repo.localRepository.retrieveFiles(for: mediaId)
        } catch {
            print(error.localizedDescription)
        }
        
        return mediaURLs
    }
    
    //FÜR DETAIL VIEW
    func matchedPlatformsFromString(_ input: String) -> [Platform] {
        Platform.matchedPlatforms(from: input)
    }
    
    //MARK: - SUPABASE FUNCTIONS
    
    ///Holt die posts von Supabase und legt sie in Swift Data an.
    func fetchAllRemotes() async {
        do {
            let remotePosts = try await repo.remoteRepository.getAllPostsRemote()
            print("remote posts fetched \(remotePosts)")
            try remotePosts.forEach { post in
                try repo.localRepository.insertInSwiftData(for: post.toPost())  // Swift Data save
                print("Saved post: \(post) in Swift Data Local Storage")
            }
            self.getAllPosts()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deletePostRemote(_ post: Post) async throws {
        try await repo.remoteRepository.deleteFile(bucket: "media-files", path: "media-files/\(String(describing: post.mediaId?.uuidString))")
    }
    
}
