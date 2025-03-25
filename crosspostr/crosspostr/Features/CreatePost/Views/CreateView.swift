import AVKit
import PhotosUI
import SwiftUI
import Combine

// MARK: - CreateView

struct CreateView: View {
    @ObservedObject var vM: CreateViewModel
    @ObservedObject var setsVM: SettingsViewModel
    @State private var showSuccessMessage = false
    @State private var authenticityScore: Double = 100
    @State private var showLowScoreWarning = false
    private let screen = UIScreen.main.bounds

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height

            ScrollView {
                VStack(spacing: 20) {
                    //                    TopBarView(vM: setsVM)
                    PlatformSelectionView(viewModel: vM)
                    DescriptionTextField(text: $vM.postText)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Authentizitäts-Score: \(Int(authenticityScore))")
                            .font(.caption)
                            .foregroundColor(authenticityScore < 40 ? .red : .green)
                            .bold()
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut, value: authenticityScore)
                        
                        if showLowScoreWarning {
                            Text("⚠️ Dein Post wirkt unnatürlich. Weniger Hashtags, mehr Persönlichkeit! 😬")
                                .font(.caption2)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.leading)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut, value: showLowScoreWarning)
                        }
                    }
                    .padding(.horizontal)
                    
                    PhotosPicker(
                        selection: $vM.selectedMedia,
                        maxSelectionCount: 10,
                        preferredItemEncoding: .automatic
                    ) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                                .fontWeight(.thin)
                            Text("Medien auswählen")
                                .font(.callout)
                                .fontWeight(.thin)
                        }
                    }
                    .photosPickerStyle(.presentation)
                    .onChange(of: vM.selectedMedia) {
                        vM.loadSelectedMedia()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(vM.images, id: \.self) { image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: screen.width / 2, maxHeight: 200)
                                        .cornerRadius(12)
                                        .transition(.move(edge: .leading))
                                        .animation(.easeInOut, value: vM.images)
                                    
                                    Button {
                                        withAnimation { vM.deleteImage(image: image) }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .padding(8)
                                    }
                                }
                            }
                            
                            ForEach(vM.videoURLs, id: \.self) { url in
                                if let player = vM.videoPlayers[url] {
                                    ZStack(alignment: .topTrailing) {
                                        CustomVideoPlayer(player: player)
                                            .frame(width: screen.width / 2, height: 200)
                                            .cornerRadius(12)
                                            .transition(.move(edge: .leading))
                                            .animation(.easeInOut, value: vM.videoURLs)
                                        
                                        Button {
                                            withAnimation { vM.deleteVideo(url: url) }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .padding(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if vM.isUploading {
                        ProgressView()
                    }
                    
                    LiquidMetalButton {
                        Task {
                            await vM.post()
                            withAnimation {
                                showSuccessMessage = false
                            }
                        }
                    }
                    
                    if showSuccessMessage {
                        Text("✅ Erfolgreich gesendet.")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .transition(.scale)
                            .animation(.easeInOut, value: showSuccessMessage)
                    }
                    
                    Spacer()
                }
                .frame(minHeight: screenHeight)
                Spacer()
                    .frame(height: 84)
            }
        }
    }
}

// MARK: - PlatformSelectionView

struct PlatformSelectionView: View {
    @ObservedObject var viewModel: CreateViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Plattformen auswählen:")
                .font(.headline)
                .fontWeight(.ultraLight)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Platform.allCases, id: \.self) { platform in
                        Button {
                            withAnimation(.easeInOut) {
                                viewModel.togglePlatformSelection(platform)
                            }
                        } label: {
                            HStack {
                                Image("\(platform.rawValue.lowercased())_icon")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text(platform.rawValue.capitalized)
                                    .padding(.leading, 4)
                                    .fontWeight(.thin)
                            }
                            .padding()
                            .background(
                                viewModel.selectedPlatforms.contains(platform)
                                    ? platformBackground(platform)
                                    : AnyView(Color.gray)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .animation(
                                .easeInOut, value: viewModel.selectedPlatforms)
                        }
                    }
                }
            }
        }
        .padding(.leading)
    }

    // Funktion zur Bestimmung des Hintergrunds als Gradient, basierend auf dem Icon
    func platformBackground(_ platform: Platform) -> AnyView {
        switch platform {
        case .snapchat:
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                    startPoint: .topLeading, endPoint: .bottomTrailing))
        case .facebook:
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.gray]),
                    startPoint: .topLeading, endPoint: .bottomTrailing))
        case .twitter:
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [Color.gray, Color.black]),
                    startPoint: .topLeading, endPoint: .bottomTrailing))
        case .instagram:
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.orange]),
                    startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

// MARK: - Preview

#Preview {
    @StateObject @Previewable var viewModel = CreateViewModel()
    @StateObject @Previewable var setsVM: SettingsViewModel =
        SettingsViewModel()
    CreateView(vM: viewModel, setsVM: setsVM)
}
