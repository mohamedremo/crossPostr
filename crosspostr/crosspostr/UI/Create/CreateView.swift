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
            
            // PhotosPicker für Medien
            PhotosPicker(
                selection: $viewModel.selectedMedia,
                maxSelectionCount: 10,
                preferredItemEncoding: .automatic
            ) {
                Label("Medien auswählen", systemImage: "photo.badge.plus")
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
            
            // Posten-Button
            Button("Posten") {
                Task { await viewModel.uploadPostToSupabase() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isUploading)
            
            if viewModel.isUploading {
                ProgressView()
            }
            
            Spacer()
        }
        .padding()
        // Fehleranzeige über Alert
        .alert("Fehler", isPresented: .constant(errorManager.currentError != nil)) {
            Button("OK", role: .cancel) { errorManager.clearError() }
        } message: {
            Text(errorManager.currentError ?? "Unbekannter Fehler")
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
                            viewModel.togglePlatformSelection(platform)
                        } label: {
                            Text(platform.rawValue.capitalized)
                                .padding()
                                .background(viewModel.selectedPlatforms.contains(platform) ? Color.purple : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @StateObject @Previewable var viewModel = CreateViewModel()
    CreateView(viewModel: viewModel)
}
