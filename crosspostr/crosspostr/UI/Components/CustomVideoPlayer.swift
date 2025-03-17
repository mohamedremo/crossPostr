import AVKit
import SwiftUI

struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspectFill // Füllt die Vorschau
        return controller
    }

    func updateUIViewController(
        _ uiViewController: AVPlayerViewController, context: Context
    ) {
        uiViewController.player = player
    }
}
