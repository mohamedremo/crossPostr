import SwiftUI

struct InfoBox: View {
    
    @State var description: String = "Deine Storys. Überall."
    var body: some View {
        ZStack {
            AppTheme.cardGradient
            HStack {
                VStack {
                    Spacer()
                    Text("💆")
                        .font(Font.custom("SF Pro", size: 60))
                        .padding(-3)
                }
                Spacer()
                VStack {
                    Text("☀️")
                        .font(Font.custom("SF Pro", size: 60))
                        .padding(-18)
                    Spacer()
                    Text("🏖️")
                        .font(Font.custom("SF Pro", size: 60))
                        .padding(-15)
                }
            }
            VStack {
                Text("crossPostr.")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .shadow(radius: 3)
                    .padding(-10)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                Text(description)
                    .fontWeight(.thin)
                    .font(.headline)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
            }
        }
        .frame(width: 339, height: 143)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
}
