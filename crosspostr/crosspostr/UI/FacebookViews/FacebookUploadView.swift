import SwiftUI
import PhotosUI

struct FacebookUploadView: View {
    @AppStorage("facebook_access_token") private var accessToken: String = ""
    @State private var selectedVideo: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var isUploading: Bool = false
    @State private var uploadMessage: String = ""
    
    var body: some View {
        VStack {
            Text("📹 Facebook Video Upload")
                .font(.title)
                .bold()
            
            // Access Token anzeigen
            if accessToken.isEmpty {
                Text("🔑 Kein Facebook-Token gespeichert")
                    .foregroundColor(.red)
            } else {
                Text("✅ Facebook verbunden")
                    .foregroundColor(.green)
                    .bold()
                Text("Token: \(accessToken.prefix(20))...") // Nur ein Teil zur Sicherheit
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider().padding(.vertical)
            
            // Video auswählen
            PhotosPicker(selection: $selectedVideo, matching: .videos, photoLibrary: .shared()) {
                HStack {
                    Image(systemName: "video.fill")
                    Text("Wähle ein Video aus")
                }
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            }
            .onChange(of: selectedVideo) { newValue in
                loadSelectedVideo()
            }
            
            if let videoURL = videoURL {
                Text("📁 Video: \(videoURL.lastPathComponent)")
                    .foregroundColor(.blue)
                    .padding(.top)
                
                Button(action: uploadVideoToFacebook) {
                    Text(isUploading ? "🚀 Hochladen..." : "📤 Video hochladen")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isUploading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(isUploading)
            }
            
            // Statusnachricht
            Text(uploadMessage)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .padding()
    }
    
    // MARK: - Video in `URL` konvertieren
    func loadSelectedVideo() {
        guard let selectedVideo = selectedVideo else { return }
        
        Task {
            do {
                if let url = try await selectedVideo.loadTransferable(type: URL.self) {
                    videoURL = url
                    print("✅ Video geladen: \(url)")
                }
            } catch {
                print("❌ Fehler beim Laden des Videos: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Video hochladen
    func uploadVideoToFacebook() {
        guard let videoURL = videoURL, !accessToken.isEmpty else {
            uploadMessage = "⚠️ Kein Video oder Access Token verfügbar!"
            return
        }

        isUploading = true
        uploadMessage = "⏳ Upload startet..."
        
        let appID = "501664873040786"
        let fileName = videoURL.lastPathComponent
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: videoURL.path)[.size] as? Int) ?? 0
        
        startUploadSession(appID: appID, fileName: fileName, fileSize: fileSize, fileType: "video/mp4", accessToken: accessToken) { sessionID in
            guard let sessionID = sessionID else {
                DispatchQueue.main.async {
                    self.uploadMessage = "❌ Fehler beim Starten der Upload-Sitzung!"
                    self.isUploading = false
                }
                return
            }

            uploadFile(sessionID: sessionID, fileURL: videoURL, accessToken: accessToken) { handle in
                DispatchQueue.main.async {
                    if let handle = handle {
                        self.uploadMessage = "🎉 Video erfolgreich hochgeladen! ✅"
                    } else {
                        self.uploadMessage = "❌ Upload fehlgeschlagen!"
                    }
                    self.isUploading = false
                }
            }
        }
    }
    /// HIER API REQUEST 
    func startUploadSession(appID: String, fileName: String, fileSize: Int, fileType: String, accessToken: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://graph.facebook.com/v22.0/\(appID)/uploads"
        var components = URLComponents(string: urlString)!
        
        components.queryItems = [
            URLQueryItem(name: "file_name", value: fileName),
            URLQueryItem(name: "file_length", value: "\(fileSize)"),
            URLQueryItem(name: "file_type", value: fileType),
            URLQueryItem(name: "access_token", value: accessToken)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Fehler beim Starten der Upload-Sitzung:", error?.localizedDescription ?? "Unbekannter Fehler")
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let uploadSessionID = json["id"] as? String {
                print("✅ Upload-Sitzung gestartet: \(uploadSessionID)")
                completion(uploadSessionID)
            } else {
                print("❌ Fehlerhafte Antwort:", String(data: data, encoding: .utf8) ?? "")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func uploadFile(sessionID: String, fileURL: URL, accessToken: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://graph.facebook.com/v22.0/upload:\(sessionID)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("OAuth \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("0", forHTTPHeaderField: "file_offset")

        let task = URLSession.shared.uploadTask(with: request, fromFile: fileURL) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Fehler beim Hochladen:", error?.localizedDescription ?? "Unbekannter Fehler")
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let uploadedFileHandle = json["h"] as? String {
                print("✅ Datei erfolgreich hochgeladen! Handle: \(uploadedFileHandle)")
                completion(uploadedFileHandle)
            } else {
                print("❌ Fehlerhafte Antwort:", String(data: data, encoding: .utf8) ?? "")
                completion(nil)
            }
        }
        task.resume()
    }
}
