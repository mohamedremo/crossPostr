import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var createVM: CreateViewModel
    @ObservedObject var setsVM: SettingsViewModel
    @ObservedObject var tabVM: TabBarViewModel

    var body: some View {
        NavigationStack {
//            TopBarView(vM: setsVM)
            ZStack {
                ScrollView {
                    VStack(spacing: 6) {
                        
                        Button {
                            withAnimation {
                                tabVM.selectedPage = .create
                            }
                        } label: {
                            DashboardNewPostCard()
                        }

                        ForEach(viewModel.posts, id: \.id) { post in
                            NavigationLink(
                                destination: PostDetailView(
                                    vM: viewModel, post: post)
                            ) {
                                DashboardCard(
                                    post: post,
                                    viewModel: viewModel
                                )
                            }
                        }
                        Spacer()
                            .frame(height: 84)  //Tab-Bar
                    }
                }
            }
        }
        .onAppear {
            viewModel.getAllPosts()
        }
    }
}

struct DashboardNewPostCard: View {

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 370, height: 140)
                .background(AppTheme.cardGradient.opacity(0.8))  //Gradient hier
                .cornerRadius(59)

            HStack {
                Spacer()
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .clipped()
                    .foregroundStyle(AppTheme.secondaryText)

                VStack(alignment: .center) {
                    Text("Create New Post")
                        .bold()
                        .padding()
                        .foregroundStyle(AppTheme.primaryText)
                        .fontWeight(.light)
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
            AppTheme.cardGradient
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
    @Previewable @StateObject var settingsVM: SettingsViewModel =
    SettingsViewModel()
    @Previewable @StateObject var tabVM: TabBarViewModel =
    TabBarViewModel()

    DashboardView(viewModel: viewModel, authVM: authVM, createVM: createVM,setsVM: settingsVM,tabVM: tabVM)
        .environmentObject(errorHandler)
}
