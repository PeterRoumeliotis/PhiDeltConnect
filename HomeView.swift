import SwiftUI

struct HomeView: View {
    @ObservedObject var postManager = PostManager()

    var body: some View {
        NavigationView {
            List(postManager.posts) { post in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 10) {
                        // Profile Picture Placeholder
                        Image("ProfilePic")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))

                        VStack(alignment: .leading, spacing: 4) {
                            // Name
                            Text(post.authorName)
                                .font(.headline)
                                .bold()

                            // Subtitle
                            Text(post.authorSubtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            // Timestamp
                            Text(formatDate(post.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Post Content
                    Text(post.content)
                        .font(.body)
                        .padding(.top, 5)
                }
                .padding(.vertical, 10)
            }
            .navigationTitle("Home")
            .onAppear {
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
