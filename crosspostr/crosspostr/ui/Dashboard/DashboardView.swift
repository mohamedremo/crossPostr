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
    @ObservedObject var createVM: CreateViewModel
    @EnvironmentObject var errorManager: ErrorManager

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Mohamed Remo-")
                            .font(.headline)
                        Text("Welcome to crossPostr")
                            .font(.caption)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.clear)

                List {
                    Button {
                        viewModel.showCreatePostSheet.toggle()
                    } label: {
                        DashboardNewPostCard()
                    }

                    ForEach(viewModel.posts, id: \.id) { post in
                        ZStack {

                            DashboardCard(post: post, viewModel: viewModel)
                            NavigationLink(
                                "",
                                destination: PostDetailView(
                                    vM: viewModel, post: post)
                            )
                            .opacity(0.0)
                        }
                    }
                    Spacer() // Ein optionaler Abstand nach unten
                               .frame(height: 38) // Höhe entsprechend deiner gewünschten Toleranz
                }
                .listStyle(PlainListStyle())
                .listRowBackground(Color.clear)
                .scrollContentBackground(.hidden)
                .background(Color.clear)

            }
            .background(Color.clear)
        }
        .background(Color.clear)
        .alert("Fehler", isPresented: .constant(errorManager.currentError != nil)) {
            Button("OK", role: .cancel) { errorManager.clearError() }
        } message: {
            Text(errorManager.currentError ?? "Unbekannter Fehler")
        }
        .onAppear {
            viewModel.getAllPosts()
        }
        .sheet(
            isPresented: $viewModel.showCreatePostSheet,
            content: {
                CreateView(viewModel: createVM)
            }
        )
        .overlay {
            //Hier ProgressView rein
        }
        
    }
}

struct DashboardNewPostCard: View {

    var body: some View {
        ZStack {
            AppTheme.mainBackground.opacity(1.0)
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
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            AppTheme.mainBackground
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

#Preview {

    @Previewable @StateObject var viewModel: DashboardViewModel =
        DashboardViewModel()
    @Previewable @StateObject var authVM: AuthViewModel =
        AuthViewModel()
    @Previewable @StateObject var createVM: CreateViewModel =
        CreateViewModel()

    DashboardView(viewModel: viewModel, authVM: authVM, createVM: createVM)

}
