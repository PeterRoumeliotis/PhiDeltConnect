//  Comment.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import Foundation

// Comment is one comment on a post

struct Comment: Identifiable {
    var id: String //Firestore doc ID
    var content: String
    var timestamp: Date
    var authorName: String
    var profilePicName: String
}
