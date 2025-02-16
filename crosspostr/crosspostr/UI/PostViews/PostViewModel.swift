
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
 
import PhotosUI
import SwiftUI
import AVKit

@MainActor
class PostViewModel: ObservableObject {
    /// The text content of the post.
    @Published var postText: String = ""
    
    /// The set of selected social media platforms (e.g., Instagram).
    @Published var selectedPlatforms: Set<Platform> = [.instagram]
    
    /// The media items selected via the PhotosPicker.
    @Published var selectedMedia: [PhotosPickerItem] = []
    
    /// An array of loaded images.
    @Published var images: [UIImage] = []
    
    /// An array of URLs for loaded video files (stored temporarily).
    @Published var videoURLs: [URL] = []
    
    /// A mapping of video URLs to their corresponding persistent AVPlayer instances.
    @Published var videoPlayers: [URL: AVPlayer] = [:]
    
    /// A flag indicating whether an upload is currently in progress.
    @Published var isUploading: Bool = false

    /// Toggles the selection state of a given platform.
    /// - Parameter platform: The social media platform to toggle.
    func togglePlatformSelection(_ platform: Platform) {
        if selectedPlatforms.contains(platform) {
            selectedPlatforms.remove(platform)
        } else {
            selectedPlatforms.insert(platform)
        }
    }

    /// Clears the current post draft, removing text, selected platforms, and loaded media.
    func clear() {
        postText = ""
        selectedPlatforms.removeAll()
        selectedMedia.removeAll()
        images.removeAll()
        videoURLs.removeAll()
        videoPlayers.removeAll()
    }

    /// Asynchronously loads an image from a given PhotosPickerItem.
    /// - Parameter pickerItem: The media item to load as an image.
    /// - Returns: A `UIImage` if the loading is successful; otherwise, `nil`.
    func loadImage(from pickerItem: PhotosPickerItem) async -> UIImage? {
        if let data = try? await pickerItem.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    /// Asynchronously loads a video from a given PhotosPickerItem.
    ///
    /// This function attempts to load video data and writes it to a temporary file with a `.mov` extension.
    /// - Parameter pickerItem: The media item to load as a video.
    /// - Returns: A `URL` pointing to the temporary video file if successful; otherwise, `nil`.
    func loadVideo(from pickerItem: PhotosPickerItem) async -> URL? {
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

    /// Asynchronously loads all selected media items (both images and videos) from the PhotosPicker.
    ///
    /// The function first attempts to load an image. If that fails, it tries to load a video.
    /// Loaded videos are cached along with their AVPlayer instances .
    func loadSelectedMedia() async {
        // Clear existing media
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
    
    /// Deletes a video from the loaded media using its URL.
    /// - Parameter url: The URL of the video to delete.
    func deleteVideo(url: URL) {
        videoURLs.removeAll(where: { $0 == url })
        videoPlayers.removeValue(forKey: url)
    }
    
    /// Deletes an image from the loaded media.
    /// - Parameter image: The image to delete.
    func deleteImage(image: UIImage) {
        images.removeAll(where: { $0 == image })
    }
}
