//
//  LocalRepository.swift
//  crossPostr
//
//  Description: Local repository for managing data operations and file handling.
//  Author: Mohamed Remo
//  Version: 1.0
//

import Foundation
import Storage
import SwiftData
import UIKit

/// Handles local data persistence using SwiftData and manages temporary media storage in the cache.
@MainActor
class LocalRepository {

    // MARK: - Properties
    /// SwiftData model container used for managing local storage of `Post` and `Media` entities.
    private let modelContainer: ModelContainer
    /// For Media Uploads and Backups.
    private let supabaseClient = BackendClient.shared.supabase
    //ErroManager
    private let errorManager = ErrorManager.shared

    // MARK: - Initialization
    /**
     Initializes the local repository with a SwiftData model container.

     - Note: If the container cannot be created, the app will terminate with a fatal error.
     */
    init() {
        do {
            let schema = Schema([Post.self, Media.self, Profile.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(
                for: schema, configurations: config)
        } catch {
            print("Container could not be created.")
            fatalError()
        }
    }

    // MARK: - SwiftData Operations

    /// Inserts a new post into the local repository.
    ///
    /// - Parameter post: The `Post` object to be inserted.
    /// - Throws: An error if the insertion or saving fails.
    func insertPostObjectLocal(_ post: Post) {
        do {
            modelContainer.mainContext.insert(post)
            try modelContainer.mainContext.save()

        } catch {
            errorManager.setError(error)
        }
    }

    func insertMediaObjectLocal(_ media: Media) {
        do {
            modelContainer.mainContext.insert(media)
            try modelContainer.mainContext.save()
        } catch {
            errorManager.setError(error)
        }
    }

    func insertProfileObjectLocal(_ profile: Profile) {
        do {
            // Vorhandenes Profil löschen (es soll nur eins geben)
            let existing = try modelContainer.mainContext.fetch(
                FetchDescriptor<Profile>())
            existing.forEach { modelContainer.mainContext.delete($0) }

            modelContainer.mainContext.insert(profile)
            try modelContainer.mainContext.save()
            print("✅ Neues Profil gespeichert: \(profile.fullName)")
        } catch {
            errorManager.setError(error)
        }
    }

    func getProfileObjectLocal() -> Profile? {
        let fetchDescriptor = FetchDescriptor<Profile>(
            predicate: #Predicate<Profile> { _ in true },
            sortBy: [])
        let result = try? modelContainer.mainContext.fetch(fetchDescriptor)
        print("🔍 Gefundene Profile: \(result?.count ?? 0)")
        return result?.first
    }

    func updateProfileObjectLocal(_ profile: Profile) {
        do {
            try modelContainer.mainContext.save()
        } catch {
            errorManager.setError(error)
        }
    }

    /// Fetches all posts associated with a given user ID.
    ///
    /// - Parameter userId: The identifier of the user whose posts are to be fetched.
    /// - Returns: An array of `Post` objects.
    func fetchAllPosts(userId: String) -> [Post] {
        let predicate = #Predicate<Post> { post in
            post.userId == userId
        }
        let sortDescriptor = SortDescriptor(\Post.createdAt, order: .forward)
        let fetchDescriptor = FetchDescriptor(
            predicate: predicate, sortBy: [sortDescriptor])
        return try! modelContainer.mainContext.fetch(fetchDescriptor)
    }

    // MARK: - Media Upload Dispatcher
    /// Uploads all pending media files to Supabase.
    ///
    /// - Parameters:
    ///   - isUploading: A Boolean inout flag indicating whether an upload is in progress.
    ///   - setErrorMessage: A closure to set an error message in case of failure.
    /// - Throws: An error if the upload process fails.
    func uploadAllPendingMedia(
        isUploading: inout Bool, setErrorMessage: @escaping (String) -> Void
    ) async {
        print("🔄 Starte Upload aller Medien...")

        do {
            let fetchDescriptor = FetchDescriptor<Media>(
                predicate: #Predicate { $0.remoteURL == nil })
            let pendingMedia = try modelContainer.mainContext.fetch(
                fetchDescriptor)

            guard !pendingMedia.isEmpty else {
                print("⚠️ Keine Medien zum Hochladen gefunden.")
                return
            }

            isUploading = true

            for media in pendingMedia {
                await upload(media: media, setErrorMessage: setErrorMessage)
            }

            isUploading = false
            print("🟢 Alle Medien erfolgreich hochgeladen.")
        } catch {
            setErrorMessage(
                "Fehler beim Hochladen der Medien: \(error.localizedDescription)"
            )
        }
    }

    private func upload(
        media: Media, setErrorMessage: @escaping (String) -> Void
    ) async {
        let mediaDTO = media.toMediaDTO()

        guard let fileURL = URL(string: media.localPath) else {
            setErrorMessage("Ungültiger Pfad: \(media.localPath)")
            return
        }

        do {
            let fileData = try Data(contentsOf: fileURL)
            let uploadedURL: String?

            switch mediaDTO.type {
            case .image:
                uploadedURL = await uploadImageToSupabase(
                    mediaDTO: mediaDTO, imageData: fileData)
            case .video:
                uploadedURL = await uploadVideoToSupabase(
                    mediaDTO: mediaDTO, videoData: fileData)
            }

            guard let uploadedURL else {
                setErrorMessage("Upload fehlgeschlagen für \(media.localPath).")
                return
            }

            media.remoteURL = uploadedURL
            try modelContainer.mainContext.save()
            cleanupLocalMediaFile(fileURL: fileURL, folderId: mediaDTO.id)
            print("🟢 Datei erfolgreich hochgeladen: \(uploadedURL)")
        } catch {
            setErrorMessage(
                "Fehler beim Verarbeiten von \(media.localPath): \(error.localizedDescription)"
            )
        }
    }

    private func cleanupLocalMediaFile(fileURL: URL, folderId: UUID) {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("🗑 Datei \(fileURL.lastPathComponent) gelöscht.")

            if let folderURL = folderURL(for: folderId) {
                let remainingFiles = try FileManager.default
                    .contentsOfDirectory(
                        at: folderURL, includingPropertiesForKeys: nil)
                if remainingFiles.isEmpty {
                    try FileManager.default.removeItem(at: folderURL)
                    print(
                        "🗑 Ordner \(folderURL.lastPathComponent) gelöscht, da er jetzt leer ist."
                    )
                }
            }
        } catch {
            print(
                "Fehler beim Löschen der Datei: \(error.localizedDescription)")
        }
    }

    // MARK: - Image & Video Upload Helpers
    private func uploadImageToSupabase(mediaDTO: MediaDTO, imageData: Data)
        async -> String?
    {
        let bucket = supabaseClient.storage.from("media-files")
        do {
            let path = "\(mediaDTO.id.uuidString).jpg"
            try await bucket.upload(
                path, data: imageData, options: FileOptions(upsert: true))
            let publicURL =
                "\(APIHost.supabase)/storage/v1/object/public/media-files/\(path)"
            print("✅ Bild hochgeladen: \(publicURL)")
            return publicURL
        } catch {
            print("Upload Error: \(error.localizedDescription)")
            return nil
        }
    }

    private func uploadVideoToSupabase(mediaDTO: MediaDTO, videoData: Data)
        async -> String?
    {
        let bucket = supabaseClient.storage.from("media-files")
        do {
            let path = "\(mediaDTO.id.uuidString).mp4"
            try await bucket.upload(
                path, data: videoData, options: FileOptions(upsert: true))
            let publicURL =
                "\(APIHost.supabase)/storage/v1/object/public/media-files/\(path)"
            print("✅ Video hochgeladen: \(publicURL)")
            return publicURL
        } catch {
            print("Upload Error: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Cache Storage
    /// Stores an image in the cache directory.
    ///
    /// - Parameters:
    ///   - image: The `UIImage` to be stored.
    ///   - id: The unique identifier used to create a folder for caching.
    /// - Returns: The file URL where the image is stored.
    /// - Throws: An error if the image conversion or file write fails.
    func storeImageInCache(_ image: UIImage, id: UUID) throws -> URL {
        do {
            let folderURL = try createFolder(with: id)
            // Optional: Einzigartigen Dateinamen innerhalb des Ordners generieren
            let fileName = "image-\(UUID().uuidString).jpg"
            let fileURL = folderURL.appendingPathComponent(fileName)

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw NSError(
                    domain: "storeImageInCache", code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Bild konnte nicht konvertiert werden."
                    ])
            }
            try imageData.write(to: fileURL)
            print("Successfully stored image at \(fileURL)")
            return fileURL
        } catch {
            errorManager.setError(error)
        }
        return URL(fileURLWithPath: "")
    }

    /// Stores multiple images in the cache directory.
    ///
    /// - Parameters:
    ///   - images: An array of `UIImage` objects to be stored.
    ///   - id: The unique identifier used to create a folder for caching.
    /// - Returns: An array of file URLs where the images are stored.
    /// - Throws: An error if any image fails to be stored.
    func storeImagesInCache(_ images: [UIImage], id: UUID) throws -> [URL] {
        var storedURLs: [URL] = []
        for image in images {
            let storedURL = try storeImageInCache(image, id: id)
            storedURLs.append(storedURL)
        }
        return storedURLs
    }

    /// Stores multiple videos in the cache directory.
    ///
    /// - Parameters:
    ///   - videoURLs: An array of video file URLs to be stored.
    ///   - id: The unique identifier used to create a folder for caching.
    /// - Returns: An array of file URLs where the videos are stored.
    /// - Throws: An error if any video fails to be stored.
    func storeVideosInCache(_ videoURLs: [URL], id: UUID) throws -> [URL] {
        var storedURLs: [URL] = []
        do {
            for videoURL in videoURLs {
                let storedURL = try storeVideoInCache(videoURL, id: id)
                storedURLs.append(storedURL)
            }
        } catch {
            errorManager.setError(error)
        }
        return storedURLs
    }

    /// Stores a single video in the cache directory.
    ///
    /// - Parameters:
    ///   - videoURL: The URL of the video file to be stored.
    ///   - id: The unique identifier used to create a folder for caching.
    /// - Returns: The file URL where the video is stored.
    /// - Throws: An error if the video data cannot be read or written.
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

    // MARK: - File Handling Helpers
    private func createFolder(with id: UUID) throws -> URL {
        // 1) Hole das Cache-Verzeichnis
        guard
            let cacheURL = FileManager.default.urls(
                for: .cachesDirectory, in: .userDomainMask
            ).first
        else {
            throw NSError(
                domain: "LocalRepository",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Cache-Verzeichnis nicht gefunden."
                ]
            )
        }
        // 2) Erzeuge den Ordnerpfad basierend auf der UUID
        let folderURL = cacheURL.appendingPathComponent(id.uuidString)

        // 3) Falls der Ordner noch nicht existiert, erstelle ihn
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try FileManager.default.createDirectory(
                at: folderURL, withIntermediateDirectories: true,
                attributes: nil)
        }
        print("Created new Folder in Cache for Media with ID \(id.uuidString)")
        return folderURL
    }

    // Basisfunktion, die alle Dateien im Ordner zurückgibt
    private func allFiles(inFolderWith id: UUID) throws -> [URL] {
        let folderURL = try createFolder(with: id)
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: folderURL, includingPropertiesForKeys: nil)
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

    /// Retrieves all files stored in the cache folder for a given identifier.
    ///
    /// - Parameter id: The unique identifier corresponding to the cache folder.
    /// - Returns: An array of file URLs contained in the folder.
    /// - Throws: An error if the folder cannot be accessed or read.
    func getFiles(inFolderWith id: UUID) -> [URL] {
        do {
            return try allFiles(inFolderWith: id)
        } catch {
            errorManager.setError(error)
        }
        return []
    }

    // MARK: - Hilfsfunktion, um den Ordnerpfad basierend auf der UUID zu erhalten (ohne neuen Ordner zu erstellen)
    private func folderURL(for id: UUID) -> URL? {
        guard
            let cacheURL = FileManager.default.urls(
                for: .cachesDirectory, in: .userDomainMask
            ).first
        else { return nil }
        return cacheURL.appendingPathComponent(id.uuidString)
    }
}
