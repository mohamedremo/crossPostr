import AVKit
import PhotosUI
import SwiftData
import SwiftUI

@MainActor
class PostViewModel: ObservableObject {

    /// Der Text des Posts.
    @Published var postText: String = ""

    /// Ausgewählte Plattformen für den Post.
    @Published var selectedPlatforms: Set<Platform> = [.instagram]

    /// Ausgewählte Medien über den `PhotosPicker`.
    @Published var selectedMedia: [PhotosPickerItem] = []

    /// IDs der gespeicherten Medien.
    @Published var mediaIds: [UUID] = []

    /// Geladene Bilder (lokale Vorschau).
    @Published var images: [UIImage] = []

    /// Geladene Video-URLs (lokal gespeichert).
    @Published var videoURLs: [URL] = []

    /// Video-Player für die geladenen Videos.
    @Published var videoPlayers: [URL: AVPlayer] = [:]

    /// Gibt an, ob gerade ein Upload läuft.
    @Published var isUploading: Bool = false

    /// Fehlerhandling für UI-Alerts
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false

    private let repo: Repository = Repository.shared

    func triggerError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showAlert = true
            print("🔴 Fehler: \(message)")
        }
    }

    func togglePlatformSelection(_ platform: Platform) {
        if selectedPlatforms.contains(platform) {
            selectedPlatforms.remove(platform)
        } else {
            selectedPlatforms.insert(platform)
        }
        print("🟢 Plattformen aktualisiert: \(selectedPlatforms)")
    }

    func clear() {
        postText = ""
        selectedPlatforms.removeAll()
        selectedMedia.removeAll()
        mediaIds.removeAll()
        images.removeAll()
        videoURLs.removeAll()
        videoPlayers.removeAll()
        print("🟢 Alle Post-Daten wurden zurückgesetzt.")
    }

    func getImages() -> [(UIImage, UUID)] {
        do {
            return try repo.localRepository.getImages(mediaIds: mediaIds)
        } catch {
            print(error.localizedDescription)
            triggerError(
                message: "Fehler beim Laden der Bilder."
                    + error.localizedDescription)
        }
        return []
    }

    func getVideoURLs() -> [(URL, UUID)] {
        do {
            return try repo.localRepository.getVideoURLs(mediaIds: mediaIds)
        } catch {
            print(error.localizedDescription)
            triggerError(
                message: "Fehler beim Laden der Bilder."
                    + error.localizedDescription)
        }
        return []
    }

    // MARK: - Hilfsfunktionen
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
            triggerError(
                message: "Fehler beim Laden eines Videos aus dem Picker.")
        }
        return nil
    }

    private func loadImage(from pickerItem: PhotosPickerItem) async -> UIImage? {
        do {
            if let data = try await pickerItem.loadTransferable(
                type: Data.self),
                let image = UIImage(data: data)
            {
                return image
            }
        } catch {
            print(error.localizedDescription)
            triggerError(
                message: "Fehler beim Laden eines Bildes aus dem Picker."
                    + error.localizedDescription)
        }
        return nil
    }

    private func saveImageToLocalStorage(_ image: UIImage) -> String {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)

        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
        return fileURL.path
    }
}
