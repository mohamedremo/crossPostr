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
                    Text("Mohamed Remo-")
                        .font(.headline)
                    Text("Welcome to crossPostr")
                        .font(.caption)
                    Button("Logout") { authVM.logout() }
                    Button("getAllPosts()") { viewModel.getAllPosts() }
                }
                Spacer()
            }
            .padding()
            
            List {
                Button {
                    //Hier Navigation
                } label: {
                    DashboardNewPostCard()
                }
                
                ForEach(viewModel.posts, id: \.id) { post in
                    DashboardCard(post: post)
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = viewModel.posts.firstIndex(where: {
                                    $0.id == post.id
                                }) {
                                    viewModel.posts.remove(at: index)
                                }
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                }
            }
            .listRowBackground(Color.clear)
            .listItemTint(Color.clear)
            .listRowSeparatorTint(Color.clear)
            .listSectionSeparatorTint(Color.clear)
            .listStyle(.plain)

        }
        .overlay {
            //Hier ProgressView rein
        }
    }
}

struct DashboardNewPostCard: View {

    var body: some View {
        ZStack {
            AppTheme.blueGradient.opacity(1.0)
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 370, height: 140)
                .background(AppTheme.cardGradient.opacity(0.6))  //Gradient hier
                .cornerRadius(59)
                .blur(radius: 40)

            HStack {
                Spacer()
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .clipped()
                    .foregroundStyle(AppTheme.cardTextColor)

                VStack(alignment: .center) {
                    Text("Create New Post")
                        .bold()
                        .padding()
                        .foregroundStyle(AppTheme.cardTextColor)
                }
                Spacer()
            }
        }
        .frame(maxHeight: 140)
        .cornerRadius(30)
        .padding(.horizontal, 20)
    }
}

struct DashboardCard: View {
    @State var post: Post

    var body: some View {
        ZStack {
            AppTheme.blueGradient
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 370, height: 140)
                .background(AppTheme.cardGradient.opacity(0.6))  //Gradient hier
                .cornerRadius(59)
                .blur(radius: 40)

            HStack {

                Image(.avatarRightRead)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75)
                    .clipped()
                    .mask {
                        Circle()
                            .frame(maxWidth: 75, maxHeight: 75)
                    }

                Spacer()

                VStack(alignment: .center) {
                    Text(post.createdAt.formatted(.dateTime))
                        .bold()
                        .padding(.vertical, 5)
                        .foregroundColor(.gray)
                    Text(post.content)
                        .foregroundColor(.white)
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
