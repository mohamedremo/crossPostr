//
//  LocalRepository.swift
//  crossPostr
//
//  Beschreibung: Lokale Repository-Klasse zur Verwaltung von Datenoperationen und File-Management.
//  Author: Mohamed Remo
//  Version: 1.0
//

import Foundation
import UIKit
import SwiftData

@MainActor
class LocalRepository {
    
    // MARK: - Properties
    private let modelContainer: ModelContainer

    // MARK: - Initialization
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

    // MARK: - Core Data Operations
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

    // MARK: - Media Upload
    func uploadMediaToSupabase(mediaDTO: MediaDTO, imageData: Data) async -> String? {
        
        let supabaseURL = APIHost.supabase
        let supabaseKey = APIKey.supabase
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
                    
                    if let fileURL = URL(string: media.localPath) {
                        // Lösche nur die hochgeladene Datei
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                            print("🗑 Datei \(fileURL.lastPathComponent) gelöscht.")
                        } catch {
                            print("Fehler beim Löschen der Datei: \(error.localizedDescription)")
                        }
                        
                        // Prüfe, ob der Ordner jetzt leer ist. Wenn ja, lösche den Ordner.
                        if let folderURL = folderURL(for: mediaDTO.id) {
                            do {
                                let remainingFiles = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
                                if remainingFiles.isEmpty {
                                    try FileManager.default.removeItem(at: folderURL)
                                    print("🗑 Ordner \(folderURL.lastPathComponent) gelöscht, da er jetzt leer ist.")
                                }
                            } catch {
                                print("Fehler beim Überprüfen/Entfernen des Ordners: \(error.localizedDescription)")
                            }
                        }
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

    private func uploadImageToSupabase(mediaDTO: MediaDTO, imageData: Data) async -> String? {
        let supabaseURL = APIHost.supabase
        let supabaseKey = APIKey.supabase
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

    private func uploadVideoToSupabase(mediaDTO: MediaDTO, videoData: Data) async -> String? {
        let supabaseURL = APIHost.supabase
        let supabaseKey = APIKey.supabase
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
    
    // MARK: - Cache Storage (Bilder & Videos)
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
    
    // Mehrere Bilder ablegen
    func storeImagesInCache(_ images: [UIImage], id: UUID) throws -> [URL] {
        var storedURLs: [URL] = []
        for image in images {
            let storedURL = try storeImageInCache(image, id: id)
            storedURLs.append(storedURL)
        }
        return storedURLs
    }
    
    // Mehrere Videos ablegen
    func storeVideosInCache(_ videoURLs: [URL], id: UUID) throws -> [URL] {
        var storedURLs: [URL] = []
        for videoURL in videoURLs {
            let storedURL = try storeVideoInCache(videoURL, id: id)
            storedURLs.append(storedURL)
        }
        return storedURLs
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
    
    // MARK: - File Management
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

    private func getImageFiles(inFolderWith id: UUID) throws -> [URL] {
        let allFiles = try allFiles(inFolderWith: id)
        return allFiles.filter { $0.pathExtension.lowercased() == "jpg" }
    }

    private func getVideoFiles(inFolderWith id: UUID) throws -> [URL] {
        let allFiles = try allFiles(inFolderWith: id)
        return allFiles.filter { $0.pathExtension.lowercased() == "mp4" }
    }

    func getFiles(inFolderWith id: UUID) throws -> [URL] {
        return try allFiles(inFolderWith: id)
    }
    
    // MARK: - Hilfsfunktion, um den Ordnerpfad basierend auf der UUID zu erhalten (ohne neuen Ordner zu erstellen)
    private func folderURL(for id: UUID) -> URL? {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        return cacheURL.appendingPathComponent(id.uuidString)
    }
}
