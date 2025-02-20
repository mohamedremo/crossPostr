//
//  PostDetailViewModel.swift
//  crosspostr
//
//  Created by Mohamed Remo on 20.02.25.
//
import Foundation

@MainActor
class DashboardDetailViewModel: ObservableObject {
    
    var post = Post(id: UUID(), content: "Sheasdioasnmdioaifsaipsdngfipasngipsaipdnfgipsanpidgiaosdgnoüsadmoügiagsdg", createdAt: Date.now, mediaId: UUID(uuidString: "6FA6048D-6717-4972-942A-09B836F9E8C3")!, metadata: "amsoidmasiod", platforms: "instagram, facebook", scheduledAt: Date.distantPast, status: "posted", userId: UUID().uuidString)
    
    private let repo = Repository.shared
    
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
}
