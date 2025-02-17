import AVKit
import PhotosUI
import SwiftUI

// MARK: - Views

struct CreateView: View {
    @ObservedObject var viewModel: PostViewModel
    var screen = UIScreen.main.bounds

    var body: some View {
        VStack(spacing: 20) {
            Text("Create✨")
                .frame(maxWidth: screen.width, alignment: .leading)
                .font(.title)
                .bold()

            PlatformSelectionView(viewModel: viewModel)

            DescriptionTextField(text: $viewModel.postText)

            PhotosPicker(
                selection: $viewModel.selectedMedia,
                maxSelectionCount: 10,
                preferredItemEncoding: .automatic
            ) {
                Label("Medien auswählen", systemImage: "photo.badge.plus")
            }
            .photosPickerStyle(.presentation)
            .onChange(of: viewModel.selectedMedia) { _, _ in
                Task {
                    await viewModel.loadSelectedMedia()
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Anzeige der Bilder
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: screen.width / 2, maxHeight: 200)
                            .cornerRadius(12)
                            .transition(.move(edge: .leading)) 
                            .animation(
                                .easeInOut, value: viewModel.videoURLs
                            )
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    withAnimation{
                                        viewModel.deleteImage(image: image)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .padding(8)
                                }
                            }
                    }

                    // Anzeige der Videos
                    ForEach(viewModel.videoURLs, id: \.self) { url in
                        if let player = viewModel.videoPlayers[url] {
                            CustomVideoPlayer(player: player)
                                .frame(width: screen.width / 2, height: 200)
                                .cornerRadius(12)
                                .transition(.move(edge: .leading))  // Animiert das Herausgleiten
                                .animation(
                                    .easeInOut, value: viewModel.videoURLs
                                )
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        withAnimation {
                                            viewModel.deleteVideo(url: url)
                                        }
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

            Button("Posten") {
                // Hier Logik zum Posten
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isUploading)

            if viewModel.isUploading {
                ProgressView()
            }
            Spacer()
        }
        .padding()
        .onTapGesture {
            Utils.shared.hideKeyboard()
        }
    }
}

struct PlatformSelectionView: View {
    @ObservedObject var viewModel: PostViewModel
    var body: some View {
        VStack(alignment: .leading) {
            Text("Plattformen auswählen:")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(
                        Platform.allCases.filter { $0.isSupported },
                        id: \.self
                    ) { platform in
                        Button(action: {
                            viewModel.togglePlatformSelection(platform)
                        }) {
                            Text(platform.rawValue.capitalized)
                                .padding()
                                .background(
                                    viewModel.selectedPlatforms.contains(
                                        platform)
                                        ? Color.purple : Color.gray
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    @StateObject @Previewable var viewModel: PostViewModel = PostViewModel()
    CreateView(viewModel: viewModel)
}
