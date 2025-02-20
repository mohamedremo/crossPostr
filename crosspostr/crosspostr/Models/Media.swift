//
//  Media.swift
//  crosspostr
//
//  Created by Mohamed Remo on 19.02.25.
//
import Foundation
import SwiftData
import PhotosUI
import SwiftUI

@Model
class Media: Identifiable {
    @Attribute(.unique) var id: UUID
    var localPath: String  // 📂 Lokaler Pfad z. B. "file:///var/mobile/Containers/..."
    var type: MediaType
    var createdAt: Date?
    var remoteURL: String? // 🌐 Falls es hochgeladen wurde

    init(id: UUID = UUID(), localPath: String, type: MediaType, createdAt: Date? = nil, remoteURL: String? = nil) {
        self.id = id
        self.localPath = localPath
        self.type = type
        self.createdAt = createdAt
        self.remoteURL = remoteURL
        
    }
    
    init(mediaDTO: MediaDTO) {
        self.id = mediaDTO.id
        self.localPath = mediaDTO.url
        self.type = mediaDTO.type
        self.createdAt = mediaDTO.uploadedAt
        self.remoteURL = mediaDTO.url
    }
}

extension Media {
    func toMediaDTO() -> MediaDTO {
        return MediaDTO(from: self)
    }
}






