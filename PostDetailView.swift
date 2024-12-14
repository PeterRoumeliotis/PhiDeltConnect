import SwiftUI

struct PostDetailView: View {
    @ObservedObject var postManager: PostManager
    @ObservedObject var profileManager: ProfileManager
    
    var post: Post
    @State private var commentText: String = ""

    private var firstName: String {
        post.authorName.split(separator: " ").first.map(String.init) ?? ""
    }
    
    var body: some View {
        VStack {
            // Post Content
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
                }

                Text(post.content)
                    .font(.body)
                    .padding(.top, 5)
            }
            .padding()

            // Like and Comment functionality here
            HStack(spacing: 20) {
                // Like button and count
                HStack(spacing: 5) {
                    Button(action: {
                        postManager.incrementLike(for: post)
                    }) {
                        Image(systemName: "heart")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    Text("\(post.likeCount)")
                        .font(.caption)
                }

                Spacer()
            }
            .padding(.horizontal)

            // Comments Section
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(postManager.comments) { comment in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(alignment: .top, spacing: 10) {
                                Image("ProfilePic")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(comment.authorName)
                                        .font(.headline)
                                        .bold()

                                    Text(formatDate(comment.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }

                            Text(comment.content)
                                .font(.body)
                                .padding(.top, 5)
                        }
                        .padding(.vertical, 5)
                        .background(Color(UIColor.systemBackground))
                    }
                }
                .padding(.horizontal)
            }

            // Comment Input
            HStack {
                TextField("Add a comment...", text: $commentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)

                Button(action: {
                    guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    postManager.addComment(to: post, content: commentText, profile: profileManager.profile)
                    commentText = ""
                }) {
                    Text("Send")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("\(firstName)'s Post")
        .onAppear {
            profileManager.fetchProfile()
            postManager.fetchComments(for: post)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
