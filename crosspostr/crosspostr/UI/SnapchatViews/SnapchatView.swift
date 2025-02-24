import SwiftUI
import SCSDKCreativeKit

struct SnapchatShareView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Teile dein Bild auf Snapchat!")
                .font(.headline)
            
            Button(action: shareToSnapchat) {
                HStack {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                    Text("Auf Snapchat teilen")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }
    
    func shareToSnapchat() {
        let image = UIImage(named: "deinBildName") ?? UIImage()
        let snapPhoto = SCSDKSnapPhoto(image: image)
        let photoContent = SCSDKPhotoSnapContent(snapPhoto: snapPhoto)
        
        photoContent.attachmentUrl = "https://www.instagram.com/crosspostr"
        
        let api = SCSDKSnapAPI(content: photoContent)
        api.startSnapping { error in
            if let error = error {
                print("Fehler beim Teilen: \(error.localizedDescription)")
            } else {
                print("Erfolgreich geteilt!")
            }
        }
    }
}
