import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class PostManager: ObservableObject {
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    private let db = Firestore.firestore()
    private var postsListener: ListenerRegistration?
    private var commentsListener: ListenerRegistration?
    
    // Fetch all posts
    func fetchPosts() {
        postsListener?.remove()
        postsListener = db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    return
                }

                self.posts = snapshot?.documents.compactMap { document in
                    self.postFromDocument(document)
                } ?? []
            }
    }

    // Fetch posts by a specific user
    func fetchPostsByUserID(userID: String) {
        postsListener?.remove()
        postsListener = db.collection("posts")
            .whereField("authorID", isEqualTo: userID)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching user posts: \(error.localizedDescription)")
                    return
                }

                self.posts = snapshot?.documents.compactMap { document in
                    self.postFromDocument(document)
                } ?? []
            }
    }

    // Helper method to create a Post from a Firestore document
    private func postFromDocument(_ document: QueryDocumentSnapshot) -> Post? {
        let data = document.data()
        guard let content = data["content"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let authorName = data["authorName"] as? String,
              let authorSubtitle = data["authorSubtitle"] as? String,
              let authorID = data["authorID"] as? String else {
            return nil
        }
        
        let likeCount = data["likeCount"] as? Int ?? 0
        return Post(
            id: document.documentID,
            content: content,
            timestamp: timestamp.dateValue(),
            authorName: authorName,
            authorSubtitle: authorSubtitle,
            likeCount: likeCount,
            authorID: authorID
        )
    }

    // Save post
    func addPost(content: String, profile: Profile) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let postData: [String: Any] = [
            "content": content,
            "timestamp": Timestamp(date: Date()),
            "authorName": profile.name,
            "authorSubtitle": profile.subtitle,
            "likeCount": 0,
            "authorID": userID
        ]

        db.collection("posts").addDocument(data: postData) { error in
            if let error = error {
                print("Error saving post: \(error.localizedDescription)")
            } else {
                print("Post saved successfully!")
            }
        }
    }
    
    // Increment like count for a given post and create a notification
    func incrementLike(for post: Post) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let postRef = db.collection("posts").document(post.id)
        postRef.updateData([
            "likeCount": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print("Error updating likeCount: \(error.localizedDescription)")
            } else {
                // Create notification about the like
                self.createNotification(
                    type: "like",
                    postID: post.id,
                    senderUserID: currentUserID,
                    recipientUserID: post.authorID
                )
            }
        }
    }

    // Fetch comments for a given post
    func fetchComments(for post: Post) {
        commentsListener?.remove()
        commentsListener = db.collection("posts")
            .document(post.id)
            .collection("comments")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching comments: \(error.localizedDescription)")
                    return
                }

                self.comments = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard let content = data["content"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp,
                          let authorName = data["authorName"] as? String else {
                        return nil
                    }
                    return Comment(
                        id: document.documentID,
                        content: content,
                        timestamp: timestamp.dateValue(),
                        authorName: authorName
                    )
                } ?? []
            }
    }

    // Add a comment to a given post and create a notification
    func addComment(to post: Post, content: String, profile: Profile) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let commentData: [String: Any] = [
            "content": content,
            "timestamp": Timestamp(date: Date()),
            "authorName": profile.name,
        ]

        db.collection("posts")
            .document(post.id)
            .collection("comments")
            .addDocument(data: commentData) { error in
                if let error = error {
                    print("Error adding comment: \(error.localizedDescription)")
                } else {
                    print("Comment added successfully!")
                    // Create notification about the comment
                    self.createNotification(
                        type: "comment",
                        postID: post.id,
                        senderUserID: currentUserID,
                        recipientUserID: post.authorID
                    )
                }
            }
    }
    
    // Create a notification document in Firestore
    private func createNotification(type: String, postID: String, senderUserID: String, recipientUserID: String) {
        let notificationData: [String: Any] = [
            "type": type,                  // "like" or "comment"
            "postID": postID,
            "senderUserID": senderUserID,
            "recipientUserID": recipientUserID,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("notifications").addDocument(data: notificationData) { error in
            if let error = error {
                print("Error creating notification: \(error.localizedDescription)")
            } else {
                print("Notification created successfully!")
            }
        }
    }
}
