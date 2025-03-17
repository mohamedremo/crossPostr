import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var createVM: CreateViewModel
    @EnvironmentObject var errorManager: ErrorManager

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.mainBackground
                    .ignoresSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 6) {
                        Button(action: {
                            viewModel.showCreatePostSheet.toggle()
                        }) {
                            DashboardNewPostCard()
                        }
                        ForEach(viewModel.posts, id: \.id) { post in
                            NavigationLink(destination: PostDetailView(vM: viewModel, post: post)) {
                                DashboardCard(
                                    post: post,
                                    viewModel: viewModel
                                )
                            }
                        }
                        Spacer()
                            .frame(height: 84)
                    }
                }
                .background(Color.clear)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationTitle("Dashboard")
        }
        .background(Color.clear)
        .alert(item: $errorManager.currentError) { error in
            Alert(
                title: Text("Fehler"),
                message: Text(error.message),
                dismissButton: .default(
                    Text("OK"),
                    action: {
                        errorManager.clearError()
                    })
            )
        }
        .onAppear {
            viewModel.getAllPosts()
        }
        .sheet(
            isPresented: $viewModel.showCreatePostSheet,
            content: {
                NavigationStack {
                    CreateView(viewModel: createVM)
                        .environmentObject(errorManager)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Fertig") {
                                    viewModel.showCreatePostSheet = false
                                }
                            }
                        }
                }
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
    @State private var showDeleteAlert = false

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
        .onLongPressGesture {
            showDeleteAlert = true
        }
        .alert("Diesen Beitrag löschen?", isPresented: $showDeleteAlert) {
            Button("Löschen", role: .destructive) {
                if let index = viewModel.posts.firstIndex(where: {
                    $0.id == post.id
                }) {
                    viewModel.posts.remove(at: index)
                }
            }
            Button("Abbrechen", role: .cancel) {}
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
    @Previewable @StateObject var errorHandler: ErrorManager =
        ErrorManager.shared

    DashboardView(viewModel: viewModel, authVM: authVM, createVM: createVM)
        .environmentObject(errorHandler)
}
