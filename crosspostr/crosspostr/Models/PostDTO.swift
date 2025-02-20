//
//  PostDTO.swift
//  crosspostr
//
//  Created by Mohamed Remo on 18.02.25.
//
import Foundation

struct PostDTO: Codable, Identifiable, Sendable {
    let content: String
    let createdAt: Date
    let id: UUID
    let mediaId: UUID?
    let metadata: String
    let platforms: String
    let scheduledAt: Date
    let status: String
    let userId: String
    
    init(content: String, createdAt: Date, id: UUID, mediaId: UUID, metadata: String, platforms: String, scheduledAt: Date, status: String, userId: String) {
        self.content = content
        self.createdAt = createdAt
        self.id = id
        self.mediaId = mediaId
        self.metadata = metadata
        self.platforms = platforms
        self.scheduledAt = scheduledAt
        self.status = status
        self.userId = userId
    }
}

extension PostDTO {
    func toPost() -> Post {
        Post(
            content: self.content,
            createdAt: self.createdAt,
            id: self.id,
            mediaId: self.mediaId ?? UUID(),
            metadata: self.metadata,
            platforms: self.platforms,
            scheduledAt: self.scheduledAt,
            status: self.status,
            userId: self.userId
        )
    }
}
