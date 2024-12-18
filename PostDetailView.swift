// PostDetailView.swift
// PhiDeltConnectV2
// Peter Roumeliotis

import SwiftUI
import Firebase
import FirebaseAuth

// Shows a specific post with comments and a comment input
// Users can like/unlike the post and see who made it
//Tapping the author's profile pic shows follow/unfollow options

struct PostDetailView: View {
    @ObservedObject var postManager: PostManager
    @ObservedObject var profileManager: ProfileManager
    
    var post: Post
    @State private var commentText: String = ""
    
    // Checks follow status of who made the post
    @StateObject private var authorProfileManager: ProfileManager

    @State private var showFollowDialog = false

    init(postManager: PostManager, profileManager: ProfileManager, post: Post) {
        self.postManager = postManager
        self.profileManager = profileManager
        self.post = post
        // Initialized with the author's userID to manage follow/unfollow states
        _authorProfileManager = StateObject(wrappedValue: ProfileManager(userID: post.authorID))
    }

    private var firstName: String {
        post.authorName.split(separator: " ").first.map(String.init) ?? ""
    }
    
    var body: some View {
        VStack {
            // Post content display
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image("\(post.profilePicName)")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .onTapGesture {
                            // Show follow/unfollow dialog when tapping the profile image
                            showFollowDialog = true
                        }

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

            // Like button and count
            HStack(spacing: 20) {
                HStack(spacing: 5) {
                    Button(action: {
                        postManager.toggleLike(for: post)
                    }) {
                        Image(systemName: "heart")
                            .font(.title3)
                            // If current user has liked it, show red heart, else blue
                            .foregroundColor(post.likedBy.contains(Auth.auth().currentUser?.uid ?? "") ? .red : .blue)
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
                                Image(comment.profilePicName)
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

            // Comment input and send button
            HStack {
                TextField("Add a comment...", text: $commentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)

                Button(action: {
                    guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    // Add comment with PostManager
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
            // Fetch profile, comments, and author's profile
            profileManager.fetchProfile()
            postManager.fetchComments(for: post)
            authorProfileManager.fetchProfile()
        }
        .confirmationDialog("Profile Options", isPresented: $showFollowDialog, actions: {
            if authorProfileManager.isCurrentUserFollowing {
                Button("Unfollow") {
                    authorProfileManager.toggleFollowUser(targetUserID: post.authorID)
                }
            } else {
                Button("Follow") {
                    authorProfileManager.toggleFollowUser(targetUserID: post.authorID)
                }
            }
            Button("Cancel", role: .cancel) { }
        })
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
