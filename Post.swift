import Foundation

struct Post: Identifiable {
    var id: String
    var content: String
    var timestamp: Date
    var authorName: String
    var authorSubtitle: String
}
