import AVKit
import PhotosUI
import SwiftUI

// MARK: - CreateView

struct CreateView: View {
    @ObservedObject var viewModel: CreateViewModel
    @EnvironmentObject var errorManager: ErrorManager
    private let screen = UIScreen.main.bounds

    var body: some View {
        VStack(spacing: 20) {
            // Überschrift
            Text("Create✨")
                .frame(maxWidth: screen.width, alignment: .leading)
                .font(.title)
                .bold()
            
            // Plattform-Auswahl
            PlatformSelectionView(viewModel: viewModel)
            
            // Beschreibungstextfeld
            DescriptionTextField(text: $viewModel.postText)
            
            // Medien auswählen im LiquidMetalButton-Stil
            PhotosPicker(
                selection: $viewModel.selectedMedia,
                maxSelectionCount: 10,
                preferredItemEncoding: .automatic
            ) {
                HStack {
                    Image(systemName: "photo.badge.plus")
                    Text("Medien auswählen")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .photosPickerStyle(.presentation)
            .onChange(of: viewModel.selectedMedia) { _, _ in
                Task { await viewModel.loadSelectedMedia() }
            }
            
            // Horizontale ScrollView für Bilder und Videos
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.images, id: \.self) { image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: screen.width / 2, maxHeight: 200)
                                .cornerRadius(12)
                                .transition(.move(edge: .leading))
                                .animation(.easeInOut, value: viewModel.images)
                            
                            Button {
                                withAnimation { viewModel.deleteImage(image: image) }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .padding(8)
                            }
                        }
                    }
                    
                    ForEach(viewModel.videoURLs, id: \.self) { url in
                        if let player = viewModel.videoPlayers[url] {
                            ZStack(alignment: .topTrailing) {
                                CustomVideoPlayer(player: player)
                                    .frame(width: screen.width / 2, height: 200)
                                    .cornerRadius(12)
                                    .transition(.move(edge: .leading))
                                    .animation(.easeInOut, value: viewModel.videoURLs)
                                
                                Button {
                                    withAnimation { viewModel.deleteVideo(url: url) }
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
            
            if viewModel.isUploading {
                ProgressView()
            }

            LiquidMetalButton {
                Task {
//                    await viewModel.uploadPostToSupabase()
                    await viewModel.postToTwitter()
                }
            }
            
            Spacer()
        }
        .padding()
        // Fehleranzeige über Alert
        .alert("Fehler", isPresented: .constant(errorManager.currentError != nil)) {
            Button("OK", role: .cancel) { errorManager.clearError() }
        } message: {
            Text(errorManager.currentError?.message ?? "Unbekannter Fehler")
        }
        .onTapGesture {
            Utils.shared.hideKeyboard()
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
                            }
                            .padding()
                            .background(
                                viewModel.selectedPlatforms.contains(platform) ? platformBackground(platform) : AnyView(Color.gray)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .animation(.easeInOut, value: viewModel.selectedPlatforms)
                        }
                    }
                }
            }
        }
    }
    
    // Funktion zur Bestimmung des Hintergrunds als Gradient, basierend auf dem Icon
    func platformBackground(_ platform: Platform) -> AnyView {
        switch platform {
        case .snapchat:
            // Beispielgradient mit zwei Farben aus dem Snapchat-Icon
            return AnyView(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case .facebook:
            // Zwei Blautöne, die zum Facebook-Icon passen
            return AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue, Color("FacebookLightBlue")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case .twitter:
            // Da Twitter jetzt "X" ist, verwenden wir einen dunklen Gradient
            return AnyView(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case .instagram:
            // Instagram-typischer Gradient
            return AnyView(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

// MARK: - Preview

#Preview {
    @StateObject @Previewable var viewModel = CreateViewModel()
    @StateObject @Previewable var errorHandler = ErrorManager.shared
    CreateView(viewModel: viewModel)
        .environmentObject(errorHandler)
}
