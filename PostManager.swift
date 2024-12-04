// PostManager.swift
// PhiDeltConnectV2
// Peter Roumeliotis

import SwiftUI

//Post Model
struct Post: Identifiable {
    var id = UUID()
    var profile: String
    var content: String
    var imageName: String? // Optional image name
    var likeCount: Int
    var comments: [String]
}

//Post Manager
class PostManager: ObservableObject {
    @Published var posts: [Post] = [
        Post(
            profile: "Peter Roumeliotis",
            content: "This is the first post with an image.",
            imageName: "sampleImage1",
            likeCount: 34,
            comments: ["Amazing!", "Love this!", "So cool!"]
        ),
        Post(
            profile: "Peter Roumeliotis",
            content: "This is a text-only post.",
            likeCount: 12,
            comments: ["Interesting perspective.", "Thanks for sharing."]
        )
    ]
    
    func addPost(_ post: Post) {
        posts.append(post)
    }
}
