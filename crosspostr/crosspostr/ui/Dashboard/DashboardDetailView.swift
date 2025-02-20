//
//  PostDetailView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 20.02.25.
//
import SwiftUI
import AVKit
import PhotosUI

struct DashboardDetailView: View {
//    @Binding var post: Post
    @ObservedObject var vM: DashboardDetailViewModel
    var body: some View {
        VStack {
            Text("\(vM.post.createdAt)")
            Image(systemName: "photo")
                .resizable()
                .frame(width: 75, height: 75)
                .scaledToFit()
                .mask(Circle())
            Text(vM.post.content)
            ScrollView(.horizontal) {
                MediaListView(urls: vM.getMediaFilesForPost(vM.post))
            }
        }
    }
}

struct MediaListView: View {
    let urls: [URL]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(urls, id: \.self) { url in
                    if url.pathExtension.lowercased() == "mp4" {
                        // Video anzeigen mit VideoPlayer (benötigt AVKit)
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 200)
                            .cornerRadius(8)
                    } else if url.pathExtension.lowercased() == "jpg" || url.pathExtension.lowercased() == "jpeg" {
                        // Bild anzeigen, hier laden wir die Daten synchron
                        if let imageData = try? Data(contentsOf: url),
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(8)
                        } else {
                            Text("Bild konnte nicht geladen werden")
                                .foregroundColor(.red)
                        }
                    } else {
                        Text("Unbekannter Medientyp")
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @StateObject var vM = DashboardDetailViewModel()
    DashboardDetailView(vM: vM)
}
