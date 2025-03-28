//
//  CreateViewModel.swift
//  crosspostr
//
//  Description: ViewModel for managing post creation logic including text, media selection, validation and multi-platform upload handling.
//  Author: Mohamed Remo
//  Created on: [Datum einfügen]
//

import AVKit
import PhotosUI
import SwiftUI
import Combine

/// Handles post creation logic including text input, media loading, platform selection, and post submission to remote backends and social media APIs.
@MainActor
class CreateViewModel: ObservableObject {

    @Published var postText: String = ""

    @Published var selectedPlatforms: Set<Platform> = [.instagram]

    @Published var selectedMedia: [PhotosPickerItem] = []

    @Published var images: [UIImage] = []

    @Published var videoURLs: [URL] = []

    @Published var videoPlayers: [URL: AVPlayer] = [:]

    @Published var isUploading: Bool = false

    @Published var errorMessage = ""
    
    @Published var showSuccessMessage: Bool = false

    private let repo = Repository.shared
    private let socialManager = SocialManager.shared
    private let errorManager = ErrorManager.shared

    /// Toggles the selection state of a given social media platform.
    func togglePlatformSelection(_ platform: Platform) {
        if selectedPlatforms.contains(platform) {
            selectedPlatforms.remove(platform)
        } else {
            selectedPlatforms.insert(platform)
        }
    }

    /// Loads selected images and videos asynchronously from the PhotosPicker and populates local arrays and video players.
    func loadSelectedMedia() {
        images.removeAll()
        videoURLs.removeAll()
        videoPlayers.removeAll()

        Task {
            for item in selectedMedia {
                if let image = await loadImage(from: item) {
                    images.append(image)
                    print("Bild geladen: \(image)")
                } else if let videoURL = await loadVideo(from: item) {
                    print("Video geladen: \(videoURL)")
                    videoURLs.append(videoURL)
                    videoPlayers[videoURL] = AVPlayer(url: videoURL)
                } else {
                    print("Laden des Mediums fehlgeschlagen für: \(item)")
                }
            }
        }
    }

    /// Removes a video and its associated AVPlayer instance from the view model.
    ///
    /// - Parameter url: The URL of the video to remove.
    func deleteVideo(url: URL) {
        videoURLs.removeAll(where: { $0 == url })
        videoPlayers.removeValue(forKey: url)
    }

    /// Removes an image from the list of loaded images.
    ///
    /// - Parameter image: The UIImage to remove.
    func deleteImage(image: UIImage) {
        images.removeAll(where: { $0 == image })
    }

    /// Creates a Post and sends it to Twitter using the SocialManager.
    func postToTwitter() {
        let newPost = Post(
            content: postText,
            createdAt: Date.now,
            id: UUID(),
            mediaId: UUID(),
            metadata: "",
            platforms: commaifySelectedPlatforms(),
            scheduledAt: Date.distantPast,
            status: "posted",
            userId: "UUID()"
        )
        print(newPost)

        Task {
            do {
                try await socialManager.post(post: newPost, to: .twitter)
                showSuccessMessage = true
                print("Tweet erfolgreich gesendet.")
            } catch {
                errorManager.setError(error)
            }
        }
    }

    /// Handles local caching, media upload and post submission to Supabase database.
    func uploadPostToSupabase() {

        guard let currentUser = repo.currentUser else {
            print("No current user logged in")
            return

        }
        let newMediaId: UUID = UUID()

        var medias: [MediaDTO] = []

        // Bilder hochladen
        do {
            isUploading = true
            let imageURLs = try repo.localRepository.storeImagesInCache(
                images, id: newMediaId)
            for imageURL in imageURLs {
                let newImage = MediaDTO(
                    id: newMediaId,
                    devicePath: imageURL.absoluteString,
                    url: "",
                    type: .image,
                    uploadedAt: Date.now
                )
                medias.append(newImage)
                
                if let data = try? Data(contentsOf: imageURL) {
                    // Jetzt übergeben wir sie an unsere Uploadfunktion
                    uploadMediaToSupabaseStorage(media: newImage, data: data)
                } else {
                    print(
                        "Fehler: Konnte das Bild nicht als Data laden: \(imageURL)"
                    )
                }
            }
            isUploading = false
        } catch {
            errorManager.setError(error)
        }

        // Videos hochladen
        do {
            isUploading = true
            let videoCacheURLs = try repo.localRepository.storeVideosInCache(
                videoURLs, id: newMediaId)
            for videoURL in videoCacheURLs {
                let newVideo = MediaDTO(
                    id: newMediaId,
                    devicePath: videoURL.absoluteString,
                    url: "",
                    type: .video,
                    uploadedAt: Date.now
                )
                medias.append(newVideo)

                // Datei als Data laden
                if let data = try? Data(contentsOf: videoURL) {
                    uploadMediaToSupabaseStorage(media: newVideo, data: data)
                } else {
                    print(
                        "Fehler: Konnte Video nicht als Data laden: \(videoURL)"
                    )
                }
            }
            isUploading = false
        } catch {
            errorManager.setError(error)
        }

        let newPost = PostDTO(
            content: postText,
            createdAt: Date.now,
            id: UUID(),
            mediaId: newMediaId,
            platforms: commaifySelectedPlatforms(),
            scheduledAt: Date.distantPast,
            status: "posted",
            userId: currentUser.uid
        )

        Task {
            isUploading = true
            await repo.remoteRepository.insertPostObjectRemote(
                newPost: newPost)
            isUploading = false
        }
        isUploading = false
        clear()
    }

    /// Validates the current post and dispatches it to selected social platforms using the SocialManager.
    func post() async {
        // Prüfe, ob ein Post-Text eingegeben wurde
        guard postText.count >= 5 else {
            errorManager.setError(AppError.postTextTooShort)
            return
        }
        
        guard !postText.isEmpty && !selectedPlatforms.isEmpty else {
            errorManager.setError(AppError.postTextEmpty)
            return
        }

        // Für jede ausgewählte Plattform prüfen wir individuelle Bedingungen
        for platform in selectedPlatforms {
            if let provider = OAuthProvider(rawValue: platform.rawValue) {
                // Bei Instagram muss auch ein Bild oder Video vorhanden sein
                if provider == .instagram {
                    if images.isEmpty && videoURLs.isEmpty {
                        let msg =
                            "Instagram-Post erfordert ein Bild oder Video."
                        errorMessage = msg
                        print(msg)
                        continue  // Überspringe Instagram, wenn keine Medien vorhanden sind
                    }
                }

                // Erstelle den Post
                let newPost: Post = Post(
                    content: postText,
                    createdAt: Date.now,
                    metadata: "",
                    platforms: commaifySelectedPlatforms(),
                    scheduledAt: Date.distantFuture,
                    status: "posted",
                    userId: repo.currentUser?.uid ?? "Unknown"
                )
                

                do {
                    try await socialManager.post(post: newPost, to: provider)
                    clear()
                } catch {
                    errorManager.setError(error)
                    errorMessage =
                        "Fehler beim Posten auf \(provider.rawValue)."
                }
            }
            
        }
    }

    /// Uploads a media file to Supabase storage and updates the media entry in the database.
    ///
    /// - Parameters:
    ///   - media: Media metadata to store in DB.
    ///   - data: Raw media data to upload.
    func uploadMediaToSupabaseStorage(media: MediaDTO, data: Data) {
        guard let uid = repo.currentUser?.uid else { return }

        // Bestimme die Dateiendung abhängig vom Medientyp
        let fileExt: String
        switch media.type {
        case .image:
            fileExt = "jpg"
        case .video:
            fileExt = "mp4"
        }

        // Erzeuge einen eindeutigen Dateinamen mit UUID
        let uniqueFileName = "\(UUID().uuidString).\(fileExt)"

        // Zusammengesetzter Pfad in Supabase
        let filePath = "\(uid)/\(uniqueFileName)"

        // Datei in Supabase hochladen
        Task {
            await repo.remoteRepository.uploadDataToSupabaseStorage(
                bucket: "media-files",
                path: filePath,
                fileData: data
            )
        }

        // Falls du in Supabase einen öffentlichen Bucket hast, kannst du die URL so konstruieren:
        let publicURL =
            "https://<supabase_url>/storage/v1/object/public/media-files/\(filePath)"

        // Aktualisiere das media-Objekt
        var updatedMedia = media
        updatedMedia.url = publicURL

        // Jetzt Insert in deine DB
        Task {
            await repo.remoteRepository.insertMediaObjectRemote(
                newMedia: updatedMedia)
        }
    }

    /// Clears all current post data and resets state variables.
    private func clear() {
        postText = ""
        selectedPlatforms.removeAll()
        selectedMedia.removeAll()
        images.removeAll()
        videoURLs.removeAll()
        videoPlayers.removeAll()
        isUploading = false
        errorMessage = ""

    }

    /// Converts selected platform set to comma-separated string.
    private func commaifySelectedPlatforms() -> String {
        selectedPlatforms.map { $0.rawValue }
            .joined(separator: ", ")
    }

    /// Loads an image from a PhotosPickerItem asynchronously.
    private func loadImage(from pickerItem: PhotosPickerItem) async -> UIImage?
    {
        do {
            if let data = try await pickerItem.loadTransferable(
                type: Data.self),
                let image = UIImage(data: data)
            {
                return image
            }
        } catch {
            errorManager.setError(error)
        }
        return nil
    }

    /// Loads a video file from a PhotosPickerItem asynchronously and stores it in a temporary location.
    private func loadVideo(from pickerItem: PhotosPickerItem) async -> URL? {
        do {
            if let videoData = try await pickerItem.loadTransferable(
                type: Data.self)
            {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mov")
                try videoData.write(to: tempURL)
                return tempURL
            }
        } catch {
            errorManager.setError(error)
        }
        return nil
    }
}
