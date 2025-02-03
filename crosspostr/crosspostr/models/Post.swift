//
//  Draft.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//
import Foundation

/*

 /// - Author: Mohamed Remo
 /// - Version: 1.0
 ///
 */

struct Post: Identifiable, Codable {
    let id: String
    let userId: String
    var content: String?
    var media: [MediaItem]
    let createdAt: Date
    var scheduledAt: Date?
    var platforms: [Platform]
    var status: PostStatus
    var metadata: [String: PlatformMetadata]

    init(
        id: String,
        userId: String,
        content: String? = nil,
        media: [MediaItem],
        createdAt: Date,
        scheduledAt: Date? = nil,
        platforms: [Platform],
        status: PostStatus,
        metadata: [String: PlatformMetadata]
    ) {
        self.id = id
        self.userId = userId
        self.content = content
        self.media = media
        self.createdAt = createdAt
        self.scheduledAt = scheduledAt
        self.platforms = platforms
        self.status = status
        self.metadata = metadata
    }

    ///Optionale Constructor
    init(
        from: DraftPost,
        status: PostStatus,
        metadata: [String: PlatformMetadata]
    ) {
        self.id = from.id
        self.userId = from.userId
        self.content = from.content
        self.media = from.media
        self.createdAt = from.createdAt
        self.scheduledAt = nil
        self.platforms = from.platforms
        self.status = status
        self.metadata = metadata
    }
}

///SwiftData für Lokale Speicherung
struct DraftPost: Identifiable, Codable {
    let id: String
    let userId: String
    var content: String?
    var media: [MediaItem]
    let createdAt: Date
    var updatedAt: Date
    var platforms: [Platform]
    var isReadyToPost: Bool
    var notes: String?
}

struct MediaItem: Codable {
    let url: String  // Pfad zum Medienelement
    let type: MediaType  // .image, .video, .gif
}

enum MediaType: String, Codable {
    case image, video, gif
}

enum Platform: String, Codable {
    case twitter, facebook, instagram, linkedin, tiktok, youtube

    var metadata: PlatformMetadata {
        switch self {
        case .twitter:
            return PlatformMetadata(postId: nil, maxMediaCount: 4, maxCharacters: 280, allowedMediaTypes: [.image, .video, .gif])
        case .facebook:
            return PlatformMetadata(postId: nil, maxMediaCount: 10, maxCharacters: 63206, allowedMediaTypes: [.image, .video])
        case .instagram:
            return PlatformMetadata(postId: nil, maxMediaCount: 10, maxCharacters: 2200, allowedMediaTypes: [.image, .video])
        case .linkedin:
            return PlatformMetadata(postId: nil, maxMediaCount: 9, maxCharacters: 3000, allowedMediaTypes: [.image, .video])
        case .tiktok:
            return PlatformMetadata(postId: nil, maxMediaCount: 1, maxCharacters: 2200, allowedMediaTypes: [.video])
        case .youtube:
            return PlatformMetadata(postId: nil, maxMediaCount: 1, maxCharacters: 5000, allowedMediaTypes: [.video])
        }
    }
}

enum PostStatus: String, Codable {
    case scheduled, published, failed
}

struct PlatformMetadata: Codable {
    var postId: String?  // ID des Posts auf der Plattform Nach Post ->
    var maxMediaCount: Int
    var maxCharacters: Int
    var allowedMediaTypes: [MediaType]
}
