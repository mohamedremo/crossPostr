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
    let mediaIds: [UUID]
    let metadata: String
    let platforms: String
    let scheduledAt: Date
    let status: String
    let userId: String
}

extension PostDTO {
    func toPost() -> Post {
        Post(
            content: self.content,
            createdAt: self.createdAt,
            id: self.id,
            mediaIds: self.mediaIds,
            metadata: self.metadata,
            platforms: self.platforms,
            scheduledAt: self.scheduledAt,
            status: self.status,
            userId: self.userId
        )
    }
}
