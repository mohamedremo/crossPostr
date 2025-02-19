//
//  Dashboa.swift
//  crosspostr
//
//  Created by Mohamed Remo on 17.02.25.
//
import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var authVM: AuthViewModel
    @State var postNr = 0
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Hello, World!")
                        .font(.headline)
                    Text("Welcome to crossPostr")
                        .font(.caption)
                    Button("Logout") { authVM.logout() }
                }
            }
            .task {
                await viewModel.fetchAllRemotes()
            }
            .padding()
            
            ScrollView {
                ForEach(1..<20) { post in
                    DashboardCard(post: Post(content: "Was geht ab", createdAt: Date.now, mediaIds: [], metadata: "", platforms: "", scheduledAt: Date.distantPast, status: "finished", userId: "aksdmoksamdf+aF"), postNr: $postNr)
                }
            }
        }
    }
}

struct DashboardCard: View {
    @State var post: Post
    @Binding var postNr: Int

    var body: some View {
        ZStack {
            
            AppTheme.blueGradient
    
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 370, height: 140)
                .background()//Gradient hier
                .cornerRadius(59)
                .blur(radius: 40)
            
            HStack {
                
                Circle()
                    .frame(maxWidth: 75, maxHeight: 75, alignment: .leading)
                    .overlay {
                        Image(.apple)
                        
                    }
                    .padding(.leading)
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("\(post.createdAt.formatted(.dateTime))")
                        .bold()
                        .padding(.vertical, 5)
                    Text(post.content)
                }
                
                Spacer()
            }
        }
        .cornerRadius(30)
        .padding(.horizontal, 20)
    }
}

#Preview {
    
    @Previewable @StateObject var viewModel: DashboardViewModel =
        DashboardViewModel()
    @Previewable @StateObject var authVM: AuthViewModel =
        AuthViewModel()
    
    DashboardView(viewModel: viewModel, authVM: authVM)
        
}
