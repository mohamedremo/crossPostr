//
//  PostDetailView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 20.02.25.
//
import SwiftUI
import AVKit
import PhotosUI

struct PostDetailView: View {
    @ObservedObject var vM: DashboardViewModel
    var post: Post
    @State private var platforms: [Platform] = []
    
    init(vM: DashboardViewModel, post: Post) {
        self.vM = vM
        self.post = post
        self.platforms = Platform.matchedPlatforms(from: post.platforms)
    }
    
    var body: some View {
        ZStack{
            AppTheme.cardGradient.ignoresSafeArea()
            VStack(alignment: .leading) {
                
                Text("Post")
                    .font(.largeTitle)
                    .bold()
                
                Text("\(post.createdAt.formatted(.dateTime))")
                    .font(.caption)
                    .fontWeight(.thin)
            
                HStack {
                    ForEach(platforms, id: \.self) { platform in
                        Image(platform.details().1)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(5)
                        
                    }
                }
                
                Divider()
                
                Text("Auf Plattformen gepostet:")
                    .font(.caption)
                    .fontWeight(.thin)
                    .multilineTextAlignment(.leading)
                
                ScrollView(.horizontal) {
                    MediaListView(urls: vM.getMediaFilesForPost(post))
                }
                
                Text("Beschreibung:")
                    .font(.caption)
                    .fontWeight(.thin)
                    .multilineTextAlignment(.leading)
                
                Text(post.content)
                
                Divider()
                
                PostInteractionView(likes: 95717, comments: 9474, shares: 463)
            }
            .onAppear {
                        platforms = Platform.matchedPlatforms(from: post.platforms)
                    }
            .padding()
        }
    }
}


struct MediaListView: View {
    let urls: [URL]
    
    var body: some View {
        let axes: Axis.Set = [.horizontal]
        
        ScrollView(axes, showsIndicators: false) {
            LazyHStack(spacing: 8.0) {
                ForEach(urls, id: \.self) { url in
                    if url.pathExtension.lowercased() == "mp4" {
                        // Video anzeigen und automatisch abspielen
                        VideoPlayerView(url: url)
                            .aspectRatio(1.0, contentMode: .fit)
                            .cornerRadius(8)
                            .frame(height: 300)
                    } else if url.pathExtension.lowercased() == "jpg" || url.pathExtension.lowercased() == "jpeg" {
                        // Bild anzeigen
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

                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                       object: item,
                                                       queue: .main) { _ in
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
                        
                    HStack{
                        Image(systemName: "hand.thumbsup.fill")
                        Text("\(likes)") //
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
                        Text("\(comments)") //
                    }
                }
                .padding()
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Shares")
                        .font(.caption)
                        .fontWeight(.ultraLight)
                        
                    HStack{
                        Image(systemName: "arrow.2.squarepath")
                        Text("\(shares)") //
                    }
                        
                }
                .padding()
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var vM = DashboardViewModel()
    PostDetailView(vM: vM, post: Post(content: "Wir gehen ab brasijdfnaspijnfdijp nijp nijp npinp ijnpianfipoasundfiup nasipdufn ipsdnf jsdinf ipjsdnf pisdnf pijads afjpksvjk aspje fojisandfjioasndifjnas dijpfns ipdnfireunf jasndvkjndskjvnsdküjfpüdisnfoinsdoüfin saüdoifsüdof msajdünf üjsdanfü djsnfjsdnljüfn sadlüjfnüsjk asüdfnasdknf jsadknfjü asdnf jsaüldnfüjsadnfüjsadnfüljsdnfülsajnfüljsad", createdAt: Date.now, metadata: "oü3wjegfüojqo", platforms: "instagram, facebook, snapchat", scheduledAt: Date.distantPast, status: "posted", userId: ""))
}
