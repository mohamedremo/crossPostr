import SwiftUI
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var errorManager: ErrorManager // ErrorHandling
    @ObservedObject var vM: SettingsViewModel
    @State var selectedItem: PhotosPickerItem? = nil
    var image: UIImage? = nil
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if let urlString = vM.mainProfile?.profileImageUrl {
                        AsyncImage(url: URL(string: urlString))
                            .frame(width: 125, height: 125)
                            .mask(Circle())
                            .padding(.horizontal)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 75, height: 75)
                            .mask(Circle())
                            .padding(.horizontal)
                    }
                    
                    PhotosPicker(selection: $selectedItem,
                                 matching: .images,
                                 preferredItemEncoding: .automatic
                    ) {
                        Text("Bild ändern")
                            .font(.callout)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(vM.mainProfile?.fullName ?? "No Profile")
                        .font(.title)
                    Text(vM.mainProfile?.email ?? "No Profile")
                        .font(.callout)
                }
               Spacer ()
            }
            
            Form {
                Section("Accounts") {
                    Button {
                        // --- HIER AKTION ----
                    } label: {
                        ConnectLabel(image: .facebookIcon, platform: "facebook")
                        
                    }
                    
                    Button {
                        vM.connectToTwitter()
                    } label: {
                        ConnectLabel(image: .twitterIcon, platform: "X")
                    }
                    
                    Button {
                        // --- HIER AKTION ----
                    } label: {
                        ConnectLabel(image: .snapchatIcon, platform: "Snapchat")
                    }
                    
                }
                
                Section {
                    Button("Logout") {
                        vM.logout()
                    }
                    .tint(.red)
                    .buttonStyle(.borderedProminent)
                    
                    Button("Delete Keychain Data") {
                        do{
                            try KeychainManager.shared.remove("twitter_accessToken")
                            try KeychainManager.shared.remove("twitter_refreshToken")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(.clear)
            .cornerRadius(12)

        }
        .alert(item: $errorManager.currentError) { error in
            Alert(
                title: Text("Fehler"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"), action: {
                    errorManager.clearError()
                })
            )
        }
    }
}

struct ConnectLabel: View {
    var image: UIImage
    var platform: String
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .frame(width: 20, height: 20)
            Text("Connect with \(platform)")
        }
    }
}

#Preview {
    @Previewable @StateObject var vm: SettingsViewModel = SettingsViewModel()
    @Previewable @StateObject var errorHandler: ErrorManager = ErrorManager.shared
    SettingsView(vM: vm)
        .environmentObject(errorHandler)
}
