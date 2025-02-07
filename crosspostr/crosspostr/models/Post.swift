//
//  Post.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//

import Foundation

// MARK: - Overview
/**
 The `Post` and `DraftPost` structures represent scheduled and published posts in the `crosspostr` app.

 ## Description:
 - `Post`: A published or scheduled post containing metadata, media, and platform details.
 - `DraftPost`: A locally stored draft post that can be edited before publishing.
 - `MediaItem`: Represents an image, video, or GIF associated with a post.
 - `Platform`: Defines supported social media platforms.
 - `PostStatus`: Tracks the status of a post (scheduled, published, or failed).
 - `PlatformMetadata`: Stores platform-specific constraints like media limits and character restrictions.

 ## Author:
 - Mohamed Remo
 - Version: 1.0
 */

// MARK: - Published Post Model
/// Represents a published or scheduled post with metadata, media, and platform details.
struct Post: Identifiable, Codable {
    let id: String       // Unique identifier for the post
    let userId: String   // ID of the user who created the post
    var content: String? // Optional text content of the post
    var media: [MediaItem] // Associated media items (images, videos, GIFs)
    let createdAt: Date  // Timestamp when the post was created
    var scheduledAt: Date? // Optional scheduled posting time
    var platforms: [Platform] // Platforms where the post will be published
    var status: PostStatus // Current status of the post (scheduled, published, failed)
    var metadata: [String: PlatformMetadata] // Platform-specific constraints

    /// Main initializer for a `Post` object.
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

    /// Convenience initializer for creating a `Post` from a `DraftPost`.
    init(
        from draft: DraftPost,
        status: PostStatus,
        metadata: [String: PlatformMetadata]
    ) {
        self.id = draft.id
        self.userId = draft.userId
        self.content = draft.content
        self.media = draft.media
        self.createdAt = draft.createdAt
        self.scheduledAt = nil
        self.platforms = draft.platforms
        self.status = status
        self.metadata = metadata
    }
}

// MARK: - Draft Post Model
/// Represents a locally stored draft post before it is published.
struct DraftPost: Identifiable, Codable {
    let id: String       // Unique identifier for the draft
    let userId: String   // ID of the user who created the draft
    var content: String? // Optional text content
    var media: [MediaItem] // Attached media items
    let createdAt: Date  // Creation timestamp
    var updatedAt: Date  // Last updated timestamp
    var platforms: [Platform] // Target platforms for the post
    var isReadyToPost: Bool // Indicates if the draft is ready to be published
    var notes: String?   // Optional user notes
}

// MARK: - Media Item Model
/// Represents a media item such as an image, video, or GIF.
struct MediaItem: Codable {
    let url: String  // URL or local path to the media file
    let type: MediaType  // Type of media (image, video, gif)
}

// MARK: - Media Type Enum
/// Defines the type of media used in posts.
enum MediaType: String, Codable {
    case image, video, gif
}

// MARK: - Supported Platforms
/// Defines the supported social media platforms.
enum Platform: String, Codable {
    case twitter, facebook, instagram, linkedin, tiktok, youtube, snapchat

    /// Returns the default metadata for each platform.
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
        case .snapchat:
            return PlatformMetadata(postId: nil, maxMediaCount: 4, maxCharacters: 280, allowedMediaTypes: [.image, .video, .gif])
        }
    }
}

// MARK: - Post Status Enum
/// Represents the status of a post.
enum PostStatus: String, Codable {
    case scheduled, published, failed
}

// MARK: - Platform Metadata
/// Stores platform-specific constraints such as media limits and character restrictions.
struct PlatformMetadata: Codable {
    var postId: String?  // The post's ID on the external platform (if published)
    var maxMediaCount: Int // Maximum number of media items allowed
    var maxCharacters: Int // Maximum number of characters allowed
    var allowedMediaTypes: [MediaType] // Allowed media types (e.g., image, video)
}
