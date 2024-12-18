//  Post.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import Foundation

// Post is a single post.

struct Post: Identifiable {
    var id: String //Post id
    var content: String
    var timestamp: Date
    var authorName: String
    var authorSubtitle: String
    var likeCount: Int
    var authorID: String //UserID
    var profilePicName: String
    var likedBy: [String] //Array of people who liked post
}
