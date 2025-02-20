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
    var uploadedAt: Date?
    var remoteURL: String? // 🌐 Falls es hochgeladen wurde

    init(id: UUID = UUID(), localPath: String, type: MediaType, uploadedAt: Date? = nil, remoteURL: String? = nil) {
        self.id = id
        self.localPath = localPath
        self.type = type
        self.uploadedAt = uploadedAt
        self.remoteURL = remoteURL
        
    }
    
    init(mediaDTO: MediaDTO) {
        self.id = mediaDTO.id
        self.localPath = mediaDTO.url
        self.type = mediaDTO.type
        self.uploadedAt = mediaDTO.uploadedAt
        self.remoteURL = mediaDTO.url
    }
    //Diese Funktion konvertiert ein PhotosPickerItem in eine Datei auf dem Gerät und speichert sie als Media in SwiftData.
    func savePhotoPickerItems(items: [PhotosPickerItem]) async -> [UUID] {
        var savedMediaIds: [UUID] = []
        
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let fileType = item.supportedContentTypes.first?.preferredMIMEType else {
                continue
            }
            
            let isImage = fileType.starts(with: "image")
            let fileExtension = isImage ? "jpg" : "mp4"
            let mediaType: MediaType = isImage ? .image : .video
            
            // 📂 Lokalen Pfad definieren
            let fileName = UUID().uuidString + ".\(fileExtension)"
            let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            // 📥 Datei speichern
            do {
                try data.write(to: filePath)
                
                // 📝 Media-Objekt in SwiftData speichern
                let media = Media(localPath: filePath.path, type: mediaType)
                #warning("Speichern wirft fehler ?")
                modelContext?.insert(media)
                
                savedMediaIds.append(media.id)
            } catch {
                print("❌ Fehler beim Speichern: \(error)")
            }
        }
        
        return savedMediaIds
    }
    
    func getMediaById(_ id: UUID) -> Media? {
        let fetchDescriptor = FetchDescriptor<Media>(predicate: #Predicate { $0.id == id })
        return try? modelContext?.fetch(fetchDescriptor).first
    }
    
    func uploadMediaToSupabase(mediaDTO: MediaDTO, completion: @escaping (String?) -> Void) {
        guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: mediaDTO.url)) else {
            print("❌ Fehler: Datei nicht gefunden \(mediaDTO.url)")
            completion(nil)
            return
        }
        
        let fileName = "\(mediaDTO.id).jpg"
        let storageURL = "https://supabase.io/storage/\(fileName)"

        // 🔹 Fake-Upload: Ersetze mit echter Supabase-Upload-Logik
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { // Simulierter Upload
            let uploadSuccess = Bool.random() // Simulierter Erfolg/Fehlschlag

            DispatchQueue.main.async {
                if uploadSuccess {
                    print("✅ Hochgeladen: \(storageURL)")

                    // ✅ Jetzt erst `remoteURL` in SwiftData speichern
                    if let media = self.getMediaById(mediaDTO.id) {
                        media.remoteURL = storageURL
                        try? self.modelContext?.save()
                        
                        // 🗑️ Lokale Datei löschen
                        try? FileManager.default.removeItem(atPath: media.localPath)
                    }

                    completion(storageURL)
                } else {
                    print("❌ Upload fehlgeschlagen für \(mediaDTO.url)")
                    completion(nil)
                }
            }
        }
    }
    
    func uploadAllPendingMedia() throws {
        let fetchDescriptor = FetchDescriptor<Media>(predicate: #Predicate { $0.remoteURL == nil }) // Noch nicht hochgeladene Medien
        
        guard let pendingMedia = try modelContext?.fetch(fetchDescriptor) else {
            print("modelContext not available")
            return
        }

        pendingMedia.forEach { media in
            let mediaDTO = media.toMediaDTO() // ✅ Konvertiere zu DTO
            
            uploadMediaToSupabase(mediaDTO: mediaDTO) { uploadedURL in
                if let uploadedURL = uploadedURL {
                    print("✅ Hochgeladen: \(uploadedURL)")
                } else {
                    print("❌ Upload fehlgeschlagen für \(media.localPath)")
                }
            }
        }
    }}

extension Media {
    func toMediaDTO() -> MediaDTO {
        return MediaDTO(media: self)
    }
}






