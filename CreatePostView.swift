//  CreatePostView.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import SwiftUI

// Lets the user to create and submit a new post.
// Uses PostManager to add the post to Firestore and ProfileManager to get the author's profile info.

struct CreatePostView: View {
    @State private var postContent = ""
    @ObservedObject var postManager = PostManager()
    @ObservedObject var profileManager = ProfileManager()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemGray5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                Text("Create a New Post")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                ZStack(alignment: .topLeading) {
                    // Background behind where you enter text
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                    // Text editor to enter the content of post
                    TextEditor(text: $postContent)
                        .padding()
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    // Placeholder text for when you haven't typed anything
                    if postContent.isEmpty {
                        Text("Share your thoughts...")
                            .font(.body)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                }
                .frame(minHeight: 200)
                .padding(.horizontal)

                Spacer()

                // The Post button adds the post to Firestore with postManager
                Button(action: {
                    guard !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    postManager.addPost(content: postContent, profile: profileManager.profile)
                    postContent = "" // Clear after posting for the next post
                }) {
                    Text("Post")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .padding([.horizontal, .bottom])
            }
        }
        .navigationTitle("Create Post")
        .onAppear {
            // Fetch the current user profile so the post has the right details
            profileManager.fetchProfile()
        }
    }
}
