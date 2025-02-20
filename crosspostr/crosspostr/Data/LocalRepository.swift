//
//  LocalRepository.swift
//  crosspostr
//
//  Created by Mohamed Remo on 19.02.25.
//
import Foundation
import SwiftData
import UIKit

@MainActor
class LocalRepository {
    private let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([Post.self, Media.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(
                for: schema, configurations: config)
        } catch {
            print("Container could not be created.")
            fatalError()
        }
    }

    func insert(_ post: Post) throws {
        modelContainer.mainContext.insert(post)
        try modelContainer.mainContext.save()
    }

    func fetchAllPosts(userId: String) -> [Post] {
        let predicate = #Predicate<Post> { post in
            post.userId == userId
        }
        let sortDescriptor = SortDescriptor(\Post.createdAt, order: .forward)
        let fetchDescriptor = FetchDescriptor(
            predicate: predicate, sortBy: [sortDescriptor])
        return try! modelContainer.mainContext.fetch(fetchDescriptor)
    }

    func uploadMediaToSupabase(mediaDTO: MediaDTO, imageData: Data) async -> String? {
        
        let supabaseURL = apiHost.supabase
        let supabaseKey = apiKey.supabase
        let bucketName = "media-files"
        let fileName = "\(mediaDTO.id.uuidString).jpg"
        
        // URL für den Upload-Endpunkt
        guard let url = URL(string: "\(supabaseURL)/storage/v1/object/\(bucketName)/\(fileName)") else {
            print("Ungültige URL")
            return nil
        }
    
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Upload Fehler: \(response)")
                return nil
            }
            let fileURL = "\(supabaseURL)/storage/v1/object/public/\(bucketName)/\(fileName)"
            print("✅ Hochgeladen: \(fileURL)")
            return fileURL
        } catch {
            print("Upload Error: \(error.localizedDescription)")
            return nil
        }
    }

    func storeImageInCache(_ image: UIImage, id: UUID) throws -> URL {
        let folderURL = try createFolder(with: id)
        // Optional: Einzigartigen Dateinamen innerhalb des Ordners generieren
        let fileName = "image-\(UUID().uuidString).jpg"
        let fileURL = folderURL.appendingPathComponent(fileName)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "storeImageInCache", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Bild konnte nicht konvertiert werden."
            ])
        }
        try imageData.write(to: fileURL)
        print("Successfully stored image at \(fileURL)")
        return fileURL
    }
    
    func storeVideoInCache(_ videoURL: URL, id: UUID) throws -> URL {
        let folderURL = try createFolder(with: id)
        let fileName = "video-\(UUID().uuidString).mp4"
        let destinationURL = folderURL.appendingPathComponent(fileName)
        
        // Bei temporären URLs aus dem Picker evtl. SecurityScopedResource beachten
        var videoData: Data
        if videoURL.startAccessingSecurityScopedResource() {
            defer { videoURL.stopAccessingSecurityScopedResource() }
            videoData = try Data(contentsOf: videoURL)
        } else {
            videoData = try Data(contentsOf: videoURL)
        }
        
        try videoData.write(to: destinationURL)
        print("Successfully stored video at \(destinationURL)")
        return destinationURL
    }
    
    private func createFolder(with id: UUID) throws -> URL {
        // 1) Hole das Cache-Verzeichnis
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw NSError(
                domain: "LocalRepository",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Cache-Verzeichnis nicht gefunden."]
            )
        }
        // 2) Erzeuge den Ordnerpfad basierend auf der UUID
        let folderURL = cacheURL.appendingPathComponent(id.uuidString)
        
        // 3) Falls der Ordner noch nicht existiert, erstelle ihn
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
        print("Created new Folder in Cache for Media with ID \(id.uuidString)")
        return folderURL
    }
    
    // Basisfunktion, die alle Dateien im Ordner zurückgibt
    private func allFiles(inFolderWith id: UUID) throws -> [URL] {
        let folderURL = try createFolder(with: id)
        let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        return fileURLs
    }

    // Filterfunktion für Bilder
    private func getImageFiles(inFolderWith id: UUID) throws -> [URL] {
        let allFiles = try allFiles(inFolderWith: id)
        return allFiles.filter { $0.pathExtension.lowercased() == "jpg" }
    }

    // Filterfunktion für Videos
    private func getVideoFiles(inFolderWith id: UUID) throws -> [URL] {
        let allFiles = try allFiles(inFolderWith: id)
        return allFiles.filter { $0.pathExtension.lowercased() == "mp4" }
    }

    // Falls du alle Dateien (Bilder + Videos) zusammen haben möchtest:
    func getFiles(inFolderWith id: UUID) throws -> [URL] {
        return try allFiles(inFolderWith: id)
    }
    
    // MARK: - Funktion um Medien hochzuladen und sie am ende auf dem Gerät löschen
    
    func uploadAllPendingMedia(isUploading: inout Bool, setErrorMessage: @escaping (String) -> Void) async throws {
        print("🔄 Starte Upload aller Medien...")

        do {
            let fetchDescriptor = FetchDescriptor<Media>(
                predicate: #Predicate { $0.remoteURL == nil }
            )
            let pendingMedia = try modelContainer.mainContext.fetch(fetchDescriptor)
            
            guard !pendingMedia.isEmpty else {
                print("⚠️ Keine Medien zum Hochladen gefunden.")
                return
            }
            
            isUploading = true
            
            for media in pendingMedia {
                let mediaDTO = media.toMediaDTO()
                // Lade die Datei-Daten aus dem lokalen Pfad
                guard let fileURL = URL(string: media.localPath) else {
                    setErrorMessage("Ungültiger Pfad: \(media.localPath)")
                    continue
                }
                let fileData = try Data(contentsOf: fileURL)
                
                var uploadedURL: String?
                if mediaDTO.type == .image {
                    uploadedURL = await uploadImageToSupabase(mediaDTO: mediaDTO, imageData: fileData)
                } else if mediaDTO.type == .video {
                    uploadedURL = await uploadVideoToSupabase(mediaDTO: mediaDTO, videoData: fileData)
                }
                
                if let uploadedURL = uploadedURL {
                    media.remoteURL = uploadedURL
                    try? self.modelContainer.mainContext.save()
                    
                    // Lösche den kompletten Ordner im Cache, der unter der UUID gespeichert wurde
                    if let folderURL = folderURL(for: mediaDTO.id) {
                        try? FileManager.default.removeItem(at: folderURL)
                        print("🗑 Ordner \(folderURL.lastPathComponent) gelöscht.")
                    }
                    
                    print("🟢 Datei erfolgreich hochgeladen: \(uploadedURL)")
                } else {
                    setErrorMessage("Upload fehlgeschlagen für \(media.localPath).")
                }
            }
            
            isUploading = false
            print("🟢 Alle Medien erfolgreich hochgeladen.")
        } catch {
            setErrorMessage("Fehler beim Hochladen der Medien: \(error.localizedDescription)")
        }
    }
    
    // Funktion für den Upload von Bildern (wie bereits in deinem Code)
    func uploadImageToSupabase(mediaDTO: MediaDTO, imageData: Data) async -> String? {
        let supabaseURL = apiHost.supabase
        let supabaseKey = apiKey.supabase
        let bucketName = "media-files"
        let fileName = "\(mediaDTO.id.uuidString).jpg"
        
        guard let url = URL(string: "\(supabaseURL)/storage/v1/object/\(bucketName)/\(fileName)") else {
            print("Ungültige URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Upload Fehler: \(response)")
                return nil
            }
            let fileURL = "\(supabaseURL)/storage/v1/object/public/\(bucketName)/\(fileName)"
            print("✅ Bild hochgeladen: \(fileURL)")
            return fileURL
        } catch {
            print("Upload Error: \(error.localizedDescription)")
            return nil
        }
    }

    // Funktion für den Upload von Videos
    func uploadVideoToSupabase(mediaDTO: MediaDTO, videoData: Data) async -> String? {
        let supabaseURL = apiHost.supabase
        let supabaseKey = apiKey.supabase
        let bucketName = "media-files"
        let fileName = "\(mediaDTO.id.uuidString).mp4"
        
        guard let url = URL(string: "\(supabaseURL)/storage/v1/object/\(bucketName)/\(fileName)") else {
            print("Ungültige URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue("video/mp4", forHTTPHeaderField: "Content-Type")
        request.httpBody = videoData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Upload Fehler: \(response)")
                return nil
            }
            let fileURL = "\(supabaseURL)/storage/v1/object/public/\(bucketName)/\(fileName)"
            print("✅ Video hochgeladen: \(fileURL)")
            return fileURL
        } catch {
            print("Upload Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Hilfsfunktion, um den Ordnerpfad basierend auf der UUID zu erhalten (ohne neuen Ordner zu erstellen)
    private func folderURL(for id: UUID) -> URL? {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        return cacheURL.appendingPathComponent(id.uuidString)
    }
}













