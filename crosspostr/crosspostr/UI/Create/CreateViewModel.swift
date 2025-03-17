import PhotosUI
import SwiftUI
import AVKit
//  MARK: - PostViewModel Class
/**
 The `PostViewModel` class manages the state and logic for creating a new post in the crosspostr app.
 It handles text input, platform selection, and media (images and videos) loading from the PhotosPicker.
 It provides asynchronous methods for loading media and maintains persistent AVPlayer instances for video playback.
 
 ## Responsibilities:
 - Manage the post's text content.
 - Handle selection and deselection of social media platforms.
 - Load and store images and videos selected via the PhotosPicker.
 - Cache AVPlayer instances for smooth video playback.
 - Support deletion of loaded media items.
 
 ## Properties:
 - `postText`: The text content of the post.
 - `selectedPlatforms`: A set of social media platforms selected for posting.
 - `selectedMedia`: An array of media items selected via the PhotosPicker.
 - `images`: An array of loaded `UIImage` objects.
 - `videoURLs`: An array of URLs pointing to temporarily stored video files.
 - `videoPlayers`: A dictionary mapping video URLs to their corresponding `AVPlayer` instances.
 - `isUploading`: A flag indicating whether an upload process is currently active.
 
 ## Functions:
 - `togglePlatformSelection(_:)`: Toggles the selection state of a given platform.
 - `clear()`: Clears all current post data.
 - `loadImage(from:)`: Asynchronously loads an image from a provided `PhotosPickerItem`.
 - `loadVideo(from:)`: Asynchronously loads a video from a provided `PhotosPickerItem` and writes it to a temporary file.
 - `loadSelectedMedia()`: Asynchronously loads all selected media (images and videos) from the PhotosPicker.
 - `deleteVideo(url:)`: Removes a video from the loaded media using its URL.
 - `deleteImage(image:)`: Removes an image from the loaded media.
 
 ## Author:
 - Mohamed Remo
 - Version: 1.0
 */

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
    
    private let repo = Repository.shared

    func togglePlatformSelection(_ platform: Platform) {
        if selectedPlatforms.contains(platform) {
            selectedPlatforms.remove(platform)
        } else {
            selectedPlatforms.insert(platform)
        }
    }

    func loadSelectedMedia() async {
        images.removeAll()
        videoURLs.removeAll()
        videoPlayers.removeAll()
        
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
    
    func deleteVideo(url: URL) {
        videoURLs.removeAll(where: { $0 == url })
        videoPlayers.removeValue(forKey: url)
    }
    
    func deleteImage(image: UIImage) {
        images.removeAll(where: { $0 == image })
    }
    
    func uploadPostToSupabase() async {
        
        guard let currentUser = repo.currentUser else {
            print("No current user logged in")
            return
            
        }
        let newMediaId: UUID = UUID()
        
        var medias: [MediaDTO] = []
        
        // Bilder hochladen
        do {
            isUploading = true
            let imageURLs = try repo.localRepository.storeImagesInCache(images, id: newMediaId)
            for imageURL in imageURLs {
                let newImage = MediaDTO(
                    id: newMediaId,
                    devicePath: imageURL.absoluteString,
                    url: "",
                    type: .image,
                    uploadedAt: Date.now
                )
                medias.append(newImage)

                // Versuche, die Datei als Data zu laden
                if let data = try? Data(contentsOf: imageURL) {
                    // Jetzt übergeben wir sie an unsere Uploadfunktion
                    await uploadMediaToSupabaseStorage(media: newImage, data: data)
                } else {
                    print("Fehler: Konnte das Bild nicht als Data laden: \(imageURL)")
                }
            }
            isUploading = false
        } catch {
            print(error.localizedDescription)
        }

        // Videos hochladen
        do {
            isUploading = true
            let videoCacheURLs = try repo.localRepository.storeVideosInCache(videoURLs, id: newMediaId)
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
                    await uploadMediaToSupabaseStorage(media: newVideo, data: data)
                } else {
                    print("Fehler: Konnte Video nicht als Data laden: \(videoURL)")
                }
            }
            isUploading = false
        } catch {
            print(error.localizedDescription)
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
            do {
                isUploading = true
                try await repo.remoteRepository.insertPostRemote(newPost: newPost)
                isUploading = false
            } catch {
                print(error.localizedDescription)
            }
        }
        isUploading = false
        clear()
    }
    
    func uploadMediaToSupabaseStorage(media: MediaDTO, data: Data) async {
        do {
            guard let uid = repo.currentUser?.uid else { return }

            // Bestimme die Dateiendung abhängig vom Medientyp
            let fileExt: String
            switch media.type {
            case .image:
                fileExt = "jpg"
            case .video:
                fileExt = "mp4"
            default:
                fileExt = "bin" // Fallback
            }

            // Erzeuge einen eindeutigen Dateinamen mit UUID
            let uniqueFileName = "\(UUID().uuidString).\(fileExt)"

            // Zusammengesetzter Pfad in Supabase
            let filePath = "\(uid)/\(uniqueFileName)"

            // Datei in Supabase hochladen
            try await repo.remoteRepository.uploadFile(
                bucket: "media-files",
                path: filePath,
                fileData: data
            )

            // Falls du in Supabase einen öffentlichen Bucket hast, kannst du die URL so konstruieren:
            let publicURL = "https://<supabase_url>/storage/v1/object/public/media-files/\(filePath)"

            // Aktualisiere das media-Objekt
            var updatedMedia = media
            updatedMedia.url = publicURL

            // Jetzt Insert in deine DB
            try await repo.remoteRepository.insertMediaRemote(newMedia: updatedMedia)

        } catch {
            print("Fehler beim Upload in Supabase Storage: \(error.localizedDescription)")
        }
    }

    
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
    
    private func commaifySelectedPlatforms() -> String {
        selectedPlatforms.map { $0.rawValue }
            .joined(separator: ", ")
    }
    
    private func loadImage(from pickerItem: PhotosPickerItem) async -> UIImage? {
        if let data = try? await pickerItem.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    private func loadVideo(from pickerItem: PhotosPickerItem) async -> URL? {
        do {
            if let videoData = try await pickerItem.loadTransferable(type: Data.self) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mov")
                try videoData.write(to: tempURL)
                return tempURL
            }
        } catch {
            print("Fehler beim Laden des Videos: \(error)")
        }
        return nil
    }
}
