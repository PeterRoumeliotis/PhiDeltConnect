// NotificationItem.swift
// PhiDeltConnectV2
// Peter Roumeliotis

import Foundation

// A notification

struct NotificationItem: Identifiable {
    var id: String
    var type: String // Like, Comment, or Follow
    var postID: String
    var senderUserID: String
    var recipientUserID: String
    var timestamp: Date
    var senderName: String = ""
}
