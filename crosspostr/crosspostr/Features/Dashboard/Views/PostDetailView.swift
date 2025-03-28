import AVKit
import PhotosUI
import SwiftUI

struct PostDetailView: View {
    @AppStorage("showTabBar") var showTabBar: Bool = true
    @ObservedObject var vM: DashboardViewModel
    var post: Post
    @State private var platforms: [Platform] = []

    init(vM: DashboardViewModel, post: Post) {
        self.vM = vM
        self.post = post
        self.platforms = Platform.matchedPlatforms(from: post.platforms)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Auf Plattformen gepostet:")
                .font(.caption)
                .fontWeight(.thin)
                .multilineTextAlignment(.leading)

            HStack {
                ForEach(platforms, id: \.self) { platform in
                    Image(platform.details().1)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(5)
                }
            }
            .padding()
            Text("\(post.createdAt.formatted(.dateTime))")
                .font(.caption)
                .fontWeight(.thin)

            Divider()
            MediaListView(urls: vM.getMediaFilesForPost(post))

            Text("Beschreibung:")
                .font(.caption)
                .fontWeight(.thin)
                .multilineTextAlignment(.leading)
                .padding(.leading)

            Text(post.content)
            padding(.leading)

            Divider()

            PostInteractionView(likes: 95717, comments: 9474, shares: 463)
        }
        .padding()
        .onAppear {
            showTabBar = false
            platforms = Platform.matchedPlatforms(from: post.platforms)
        }
        .onDisappear {
            showTabBar = true
        }
    }

}

struct MediaListView: View {
    let urls: [URL]

    var body: some View {
        if urls.isEmpty {
            ContentUnavailableView("Keine Medien vorhanden", systemImage: "photo.stack", description: Text("Für diesen Beitrag wurden keine Bilder oder Videos gepostet."))
                .frame(width: UIScreen.main.bounds.width, height: 400)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8.0) {
                    ForEach(urls, id: \.self) { url in
                        if ["mp4", "mov"].contains(url.pathExtension.lowercased()) {
                            VideoPlayerView(url: url)
                                .aspectRatio(1.0, contentMode: .fit)
                                .cornerRadius(8)
                                .frame(height: 300)
                        } else if ["jpg", "jpeg", "png", "heic"].contains(url.pathExtension.lowercased()) {
                            if let imageData = try? Data(contentsOf: url),
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(8)
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(height: 300)
                            } else {
                                Text("Bild konnte nicht geladen werden")
                                    .foregroundColor(.red)
                            }
                        } else {
                            Text("Unbekannter Medientyp")
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                    }
                }
            }
        }
    }
}

struct VideoPlayerView: View {
    let url: URL

    @State private var player = AVPlayer()

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                let item = AVPlayerItem(url: url)
                player.replaceCurrentItem(with: item)
                player.isMuted = true
                player.actionAtItemEnd = .none

                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: item,
                    queue: .main
                ) { _ in
                    player.seek(to: .zero)
                    player.play()
                }

                player.play()
            }
    }
}

struct PostInteractionView: View {
    var likes: Int
    var comments: Int
    var shares: Int

    var body: some View {
        HStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Likes")
                        .font(.caption)
                        .fontWeight(.ultraLight)

                    HStack {
                        Image(systemName: "hand.thumbsup.fill")
                        Text("\(likes)")  //
                    }

                }
                .padding()
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Comments")
                        .font(.caption)
                        .fontWeight(.ultraLight)

                    HStack {
                        Image(systemName: "bubble.fill")
                        Text("\(comments)")  //
                    }
                }
                .padding()
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Shares")
                        .font(.caption)
                        .fontWeight(.ultraLight)

                    HStack {
                        Image(systemName: "arrow.2.squarepath")
                        Text("\(shares)")  //
                    }

                }
                .padding()
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var vM = DashboardViewModel()
    PostDetailView(
        vM: vM,
        post: Post(
            content:
                "Wir gehen ab brasijdfnaspijnfdijp nijp nijp npinp ijnpianf",
            createdAt: Date.now, metadata: "oü3wjegfüojqo",
            platforms: "instagram, facebook, snapchat",
            scheduledAt: Date.distantPast, status: "posted", userId: ""))
}
