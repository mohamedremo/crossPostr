import PhotosUI
import SwiftUI

struct SettingsView: View {
    @ObservedObject var vM: SettingsViewModel
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        VStack {
//            TopBarView(vM: vM)

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
                        authVM.logout()
                    }
                    .tint(.red)
                    .buttonStyle(.borderedProminent)

                }
            }
            .scrollContentBackground(.hidden)
            .background(.clear)
            .cornerRadius(12)
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
    @Previewable @StateObject var authVM: AuthViewModel = AuthViewModel()
    SettingsView(vM: vm, authVM: authVM)
}
