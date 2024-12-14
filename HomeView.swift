import SwiftUI

struct HomeView: View {
    @ObservedObject var postManager = PostManager()
    @ObservedObject var profileManager = ProfileManager()
    
    @State private var isSearching = false
    @State private var searchText = ""

    // Filtered posts based on search input
    private var filteredPosts: [Post] {
        if searchText.isEmpty {
            return postManager.posts
        } else {
            return postManager.posts.filter { $0.content.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Show search bar only if searching is enabled
                if isSearching {
                    HStack {
                        TextField("Search posts...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                        
                        Button(action: {
                            withAnimation {
                                isSearching = false
                                searchText = "" // Clear search when closing
                            }
                        }) {
                            Text("Cancel")
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top)
                }
                
                // List of posts - only shows posts, no like/comment buttons here
                List(filteredPosts) { post in
                    // Wrap the entire post cell content in a NavigationLink
                    NavigationLink(
                        destination: PostDetailView(
                            postManager: postManager,
                            profileManager: profileManager,
                            post: post
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 10) {
                                Image("ProfilePic")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(post.authorName)
                                        .font(.headline)
                                        .bold()

                                    Text(post.authorSubtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Text(formatDate(post.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }

                            Text(post.content)
                                .font(.body)
                                .padding(.top, 5)
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarItems(trailing: Button(action: {
                withAnimation {
                    isSearching.toggle()
                    if !isSearching {
                        searchText = "" // Clear search when closing
                    }
                }
            }) {
                Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                    .foregroundColor(.blue)
            })
            .onAppear {
                profileManager.fetchProfile()
                postManager.fetchPosts()
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
