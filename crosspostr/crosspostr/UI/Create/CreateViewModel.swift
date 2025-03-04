import PhotosUI
import SwiftUI
import AVKit

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

    // MARK: - Plattform Auswahl
    func togglePlatformSelection(_ platform: Platform) {
        if selectedPlatforms.contains(platform) {
            selectedPlatforms.remove(platform)
        } else {
            selectedPlatforms.insert(platform)
        }
    }

    // MARK: - Medien Laden
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
            print("Kein aktueller User, Upload fehlgeschlagen")
            return
        }
        
        // Gemeinsame Gruppen-ID für alle Bilder/Videos des Posts
        let newGroupId = UUID()
        // Eindeutige Post-ID
        let postId = UUID()
        
        isUploading = true
        
        // Erstelle den Post – hier wird newGroupId als Medien-Gruppe referenziert
        let newPost = PostDTO(
            content: postText,
            createdAt: Date.now,
            id: postId,
            mediaId: newGroupId, //Gemeinsame Gruppen ID
            platforms: commaifySelectedPlatforms(),
            scheduledAt: Date.distantPast,
            status: "posted",
            userId: currentUser.uid
        )
        do {
            try await repo.remoteRepository.insertPostRemote(newPost: newPost)
            print("Post erfolgreich hochgeladen")
        } catch {
            print("Fehler beim Hochladen des Posts: \(error.localizedDescription)")
        }
        
        // Bilder verarbeiten
        do {
            for image in images {
                // Eindeutige ID für diesen Medieneintrag
                
                let mediaRowId = UUID()
                let localImageURL = try repo.localRepository.storeImageInCache(image, id: newGroupId)
                print("url -> \(localImageURL.absoluteString)")
                
                let newImage = MediaDTO(
                    id: mediaRowId, // Eindeutiger Primärschlüssel für diesen Datensatz
                    userId: currentUser.uid,
                    postId: postId,
                    mediaGroupId: newGroupId, // Gemeinsame Group ID
                    devicePath: localImageURL.absoluteString,
                    type: .image,
                    uploadedAt: Date.now
                )
                
                try await repo.remoteRepository.insertMediaRemote(newMedia: newImage)
                
                // Erzeuge den Remote-Pfad im Format: "<newGroupId>/image-XYZ.jpg"
                let remotePath = "\(newGroupId.uuidString)/\(localImageURL.lastPathComponent)"
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    await repo.remoteRepository.uploadFile(path: remotePath, fileData: imageData)
                } else {
                    print("Fehler: Bilddaten konnten nicht erzeugt werden.")
                }
            }
        } catch {
            print("Fehler beim Hochladen der Bilder: \(error.localizedDescription)")
        }
        
        // Videos verarbeiten
        do {
            for video in videoURLs {
                let mediaRowId = UUID()
                let localVideoURL = try repo.localRepository.storeVideoInCache(video, id: newGroupId)
                let newVideo = MediaDTO(
                    id: mediaRowId,
                    userId: currentUser.uid,
                    postId: postId,
                    mediaGroupId: newGroupId,        // Gemeinsame Gruppen-ID
                    devicePath: localVideoURL.absoluteString,
                    type: .video,
                    uploadedAt: Date.now
                )
                try await repo.remoteRepository.insertMediaRemote(newMedia: newVideo)
                
                let remotePath = "\(newGroupId.uuidString)/\(localVideoURL.lastPathComponent)"
                let videoData = try Data(contentsOf: localVideoURL)
                await repo.remoteRepository.uploadFile(path: remotePath, fileData: videoData)
            }
        } catch {
            print("Fehler beim Hochladen der Videos: \(error.localizedDescription)")
        }
        
        isUploading = false
        clear()
    }
    
    // Alternative Methode, falls du einzelne Medien separat hochladen möchtest
    func uploadMediaToSupabaseStorage(media: MediaDTO, data: Data) async {
        do {
            guard let uid = repo.currentUser?.uid else { return }
            await repo.remoteRepository.uploadFile(path: "\(uid)/\(media.id)", fileData: data)
            try await repo.remoteRepository.insertMediaRemote(newMedia: media)
        } catch {
            print("Fehler beim Upload von Media: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Hilfsfunktionen
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
