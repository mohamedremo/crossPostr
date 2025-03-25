//
//  DashboardViewModel.swift
//  crosspostr
//
//  Description: ViewModel responsible for managing and displaying locally and remotely fetched posts, and media file access.
//  Author: Mohamed Remo
//  Created on: [Datum einfügen]
//

import SwiftUI

/// Manages the state and logic for the dashboard view, including loading posts and resolving related media files.
@MainActor
class DashboardViewModel: ObservableObject {

    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var showCreatePostSheet: Bool = false

    private var repo = Repository.shared

    /// Loads all posts for the current user from the local repository.
    func getAllPosts() {
        guard let currentUser = repo.currentUser else {
            return
        }
        self.posts = repo.localRepository.fetchAllPosts(userId: currentUser.uid)
        print("Successfully fetched local posts - \(posts)")
    }

    /// Returns an array of media file URLs associated with the given post.
    ///
    /// - Parameter post: The post whose media files should be retrieved.
    /// - Returns: An array of local file URLs, or an empty array if not found.
    func getMediaFilesForPost(_ post: Post) -> [URL] {
        guard let mediaId = post.mediaId else {
            return []
        }
        // Liefert alle Dateien im Ordner für die gegebene mediaId
        return repo.localRepository.getFiles(inFolderWith: mediaId)
    }

    /**
     Asynchronously fetches all remote posts from Supabase, stores them locally, and updates the view's post list.

     - Throws: An error if fetching or storing fails.
     */
    func fetchAllRemotes() async {
        let remotePosts = await repo.remoteRepository.getAllPostObjectsRemote()

        print("remote posts fetched \(remotePosts)")

        remotePosts.forEach { post in
            repo.localRepository.insertPostObjectLocal(post.toPost())  // Swift Data save
            print("Saved post: \(post) in Swift Data Local Storage")
        }

        self.getAllPosts()
    }

    /// Converts a comma-separated platform string into an array of `Platform` enums.
    ///
    /// - Parameter input: A string containing comma-separated platform names.
    /// - Returns: An array of matched `Platform` values.
    func matchedPlatformsFromString(_ input: String) -> [Platform] {
        Platform.matchedPlatforms(from: input)
    }

}
