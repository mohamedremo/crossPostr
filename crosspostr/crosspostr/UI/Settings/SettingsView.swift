//
//  SettingsView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 23.02.25.
//
import SwiftUI
import PhotosUI

struct SettingsView: View {
    @ObservedObject var vm: AuthViewModel
    @AppStorage("facebook_access_token") var fbToken: String = ""
    @State var selectedItem: PhotosPickerItem? = nil
    var image: UIImage? = nil
    
    @EnvironmentObject var errorManager: ErrorManager
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if let urlString = vm.mainProfile?.profileImageUrl {
                        AsyncImage(url: URL(string: urlString))
                            .frame(width: 125, height: 125)
                            .mask(Circle())
                            .padding(.horizontal)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .frame(width: 125, height: 125)
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
                    Text(vm.mainProfile?.fullName ?? "No Profile")
                        .font(.title)
                    Text(vm.mainProfile?.email ?? "No Profile")
                        .font(.callout)
                }
               Spacer ()
            }
            Form {
                Section("Persönliche Einstellungen") {
                    TextField("Facebook Access Token", text: $fbToken)
                    Button("Logout") { vm.logout() }
                }
                
            }
        }
        .alert("Fehler", isPresented: .constant(errorManager.currentError != nil)) {
            Button("OK", role: .cancel) { errorManager.clearError() }
        } message: {
            Text(errorManager.currentError ?? "Unbekannter Fehler")
        }
    }
}

#Preview {
    @Previewable @StateObject var vm: AuthViewModel = AuthViewModel()
    SettingsView(vm: vm)
}
