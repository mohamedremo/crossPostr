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

    func uploadMediaToSupabase(mediaDTO: MediaDTO, completion: @escaping (String?) -> Void) async {
        let fileName = "\(mediaDTO.id).jpg"
        let storageURL = "https://supabase.io/storage/\(fileName)"

        // Fake-Upload (2 Sekunden Verzögerung)
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        DispatchQueue.main.async {
            print("✅ Hochgeladen: \(storageURL)")
            completion(storageURL)
        }
    }

    func uploadAllPendingMedia(isUploading: inout Bool, setErrorMessage: @escaping (String) -> Void) async throws {
        print("🔄 Starte Upload aller Medien...")

        do {
            let fetchDescriptor = FetchDescriptor<Media>(
                predicate: #Predicate { $0.remoteURL == nil }
            )
            let pendingMedia = try modelContainer.mainContext.fetch(
                fetchDescriptor)

            guard !pendingMedia.isEmpty else {
                print("⚠️ Keine Medien zum Hochladen gefunden.")
                return
            }

            isUploading = true

            for media in pendingMedia {
                let mediaDTO = media.toMediaDTO()

                await uploadMediaToSupabase(mediaDTO: mediaDTO) { uploadedURL in
                    if let uploadedURL = uploadedURL {
                        media.remoteURL = uploadedURL
                        try? self.modelContainer.mainContext.save()
                        try? FileManager.default.removeItem(
                            atPath: media.localPath)
                        print("🟢 Datei erfolgreich hochgeladen: \(uploadedURL)")
                    } else {
                        setErrorMessage(
                            "Upload fehlgeschlagen für \(media.localPath).")
                    }
                }
            }

            isUploading = false
            print("🟢 Alle Medien erfolgreich hochgeladen.")
        } catch {
            setErrorMessage("Fehler beim Hochladen der Medien.")
        }
    }

    func getVideoURLs(mediaIds: [UUID]) throws -> [(URL, UUID)] {
        print("🔍 Lade Videos aus SwiftData...")

        let mediaType: String = MediaType.video.rawValue
        let fetchDescriptor = FetchDescriptor<Media>(
            predicate: #Predicate {
                mediaIds.contains($0.id) && $0.type.rawValue == mediaType
            }
        )
        let mediaList = try modelContainer.mainContext.fetch(fetchDescriptor)
        print("🟢 \(mediaList.count) Videos gefunden.")

        return mediaList.compactMap { media in
            let videoURL = URL(fileURLWithPath: media.localPath)
            return FileManager.default.fileExists(atPath: media.localPath)
                ? (videoURL, media.id) : nil
        }
    }

    func getImages(mediaIds: [UUID]) throws -> [(UIImage, UUID)] {
        print("🔍 Lade Bilder aus SwiftData...")

        do {
            let mediaType: String = MediaType.image.rawValue
            let fetchDescriptor = FetchDescriptor<Media>(
                predicate: #Predicate {
                    mediaIds.contains($0.id) && $0.type.rawValue == mediaType
                }
            )

            let mediaList = try modelContainer.mainContext.fetch(fetchDescriptor)
            print("🟢 \(mediaList.count) Bilder gefunden.")

            return mediaList.compactMap { media in
                guard let image = Utils.shared.loadUIImage(from: media.localPath) else {
                    print("⚠️ Konnte Bild nicht laden: \(media.localPath)")
                    return nil
                }
                return (image, media.id)
            }

        } catch {
            print("❌ Fehler beim Abrufen der Bilder aus SwiftData: \(error.localizedDescription)")
            return []
        }
    }
}
