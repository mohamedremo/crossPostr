import Foundation

struct MediaDTO: Codable {
    var id: UUID
    var devicePath: String
    var url: String
    var type: MediaType
    var uploadedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, url, type, uploadedAt
    }
    
    init(id: UUID, devicePath: String, url: String, type: MediaType, uploadedAt: Date) {
        self.id = id
        self.url = url
        self.devicePath = devicePath
        self.type = type
        self.uploadedAt = uploadedAt
    }
    //json decoder for enum handle
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        devicePath = try container.decode(String.self, forKey: .url)
        url = try container.decode(String.self, forKey: .url)
        uploadedAt = try container.decode(Date.self, forKey: .uploadedAt)
        let typeString = try container.decode(String.self, forKey: .type)
        type = MediaType(from: typeString) ?? .image // Fallback auf `.image`
    }
    
    
    init(from media: Media) {
        self.id = media.id
        self.devicePath = media.localPath
        self.url = media.remoteURL ?? ""
        self.type = media.type
        self.uploadedAt = media.createdAt ?? Date()
    }
}
extension MediaDTO {
    func toMedia() -> Media {
        return Media(mediaDTO: self)
    }
}
