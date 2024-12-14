import Foundation

struct Post: Identifiable {
    var id: String
    var content: String
    var timestamp: Date
    var authorName: String
    var authorSubtitle: String
    var likeCount: Int
    var authorID: String // New field to identify the author
}
