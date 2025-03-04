//
//  MediaDTO.swift
//  crosspostr
//
//  Created by Mohamed Remo on 19.02.25.
//
import Foundation

struct MediaDTO: Codable {
    var id: UUID
    var userId: String
    var postId: UUID?
    var mediaGroupId: UUID?
    var devicePath: String
    var type: MediaType
    var uploadedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, type, uploadedAt, userId, postId, devicePath, mediaGroupId
    }
    
    init(id: UUID, userId: String, postId: UUID,mediaGroupId: UUID?, devicePath: String, type: MediaType, uploadedAt: Date) {
        self.id = id
        self.devicePath = devicePath
        self.type = type
        self.uploadedAt = uploadedAt
        self.userId = userId
        self.postId = postId
        self.mediaGroupId = mediaGroupId
    }
    
    //json decoder for enum handle
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        devicePath = try container.decode(String.self, forKey: .devicePath)
        uploadedAt = try container.decode(Date.self, forKey: .uploadedAt)
        let typeString = try container.decode(String.self, forKey: .type)
        type = MediaType(from: typeString) ?? .image 
        userId = try container.decode(String.self, forKey: .userId)
        postId = try container.decode(UUID.self, forKey: .postId)
        mediaGroupId = try container.decode(UUID.self, forKey: .mediaGroupId)
    }
    
    @MainActor
    init(from media: Media) {
        self.id = media.id
        self.devicePath = media.localPath
        self.type = media.type
        self.uploadedAt = media.createdAt ?? Date()
        self.userId = Repository.shared.currentUser?.uid ?? ""
    }
}
extension MediaDTO {
    func toMedia() -> Media {
        return Media(mediaDTO: self)
    }
}
