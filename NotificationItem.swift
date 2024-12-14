import Foundation

struct NotificationItem: Identifiable {
    var id: String
    var type: String      // "like" or "comment"
    var postID: String
    var senderUserID: String
    var recipientUserID: String
    var timestamp: Date
    var senderName: String = "" // New field for sender's profile name
}
