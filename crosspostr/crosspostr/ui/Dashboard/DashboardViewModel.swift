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

    @Published var mockPosts: [Post] = [
        Post(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
             content: "Post 1: Hardcoded content",
             createdAt: Date(timeIntervalSince1970: 1609459200),
             mediaId: UUID(),
             metadata: "Metadata 1",
             platforms: "Instagram",
             scheduledAt: Date(timeIntervalSince1970: 1609462800),
             status: "published",
             userId: "User1"),
        
        Post(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
             content: "Post 2: Hardcoded content",
             createdAt: Date(timeIntervalSince1970: 1609459201),
             mediaId: UUID(),
             metadata: "Metadata 2",
             platforms: "Facebook",
             scheduledAt: Date(timeIntervalSince1970: 1609462801),
             status: "published",
             userId: "User2"),
        
        Post(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
             content: "Post 3: Hardcoded content",
             createdAt: Date(timeIntervalSince1970: 1609459202),
             mediaId: UUID(),
             metadata: "Metadata 3",
             platforms: "Twitter",
             scheduledAt: Date(timeIntervalSince1970: 1609462802),
             status: "published",
             userId: "User3"),
        
        Post(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
             content: "Post 4: Hardcoded content",
             createdAt: Date(timeIntervalSince1970: 1609459203),
             mediaId: UUID(),
             metadata: "Metadata 4",
             platforms: "LinkedIn",
             scheduledAt: Date(timeIntervalSince1970: 1609462803),
             status: "published",
             userId: "User4"),
        
        Post(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
             content: "Post 5: Hardcoded content",
             createdAt: Date(timeIntervalSince1970: 1609459204),
             mediaId: UUID(),
             metadata: "Metadata 5",
             platforms: "Instagram",
             scheduledAt: Date(timeIntervalSince1970: 1609462804),
             status: "published",
             userId: "User5"),
    ]
    
    

    private var repo = Repository.shared
    
    func getAllPosts() {
        guard let currentUser = repo.currentUser else {
            return
        }
        self.posts = repo.localRepository.fetchAllPosts(userId: currentUser.uid)
        print("Successfully fetched local posts - \(posts)")
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
