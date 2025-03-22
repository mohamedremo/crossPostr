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
    
    func getMediaFilesForPost(_ post: Post) -> [URL] {
        guard let mediaId = post.mediaId else {
            return []
        }
        
        do {
            // Liefert alle Dateien im Ordner für die gegebene mediaId
            return try repo.localRepository.getFiles(inFolderWith: mediaId)
        } catch {
            // Falls ein Fehler auftritt, geben wir ein leeres Array zurück
            print("Fehler beim Lesen der Dateien: \(error.localizedDescription)")
            return []
        }
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
    
    //FÜR DETAIL VIEW
    func matchedPlatformsFromString(_ input: String) -> [Platform] {
        Platform.matchedPlatforms(from: input)
    }
    
}
