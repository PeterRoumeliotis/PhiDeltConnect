// PostManager.swift
// PhiDeltConnectV2
// Peter Roumeliotis

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

// Manages posts and comments
// Fetches posts from Firestore, fetches comments, adds posts/comments, toggles likes, and creates notifications

class PostManager: ObservableObject {
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    private let db = Firestore.firestore()
    private var postsListener: ListenerRegistration?
    private var commentsListener: ListenerRegistration?

    // Gets posts collection ordered by time of post
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

    // Gets posts from a specific user
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

    // Converts a Firestore document into a Post model.
    private func postFromDocument(_ document: QueryDocumentSnapshot) -> Post? {
        let data = document.data()
        guard let content = data["content"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let authorName = data["authorName"] as? String,
              let authorSubtitle = data["authorSubtitle"] as? String,
              let authorID = data["authorID"] as? String,
              let profilePicName = data["profilePicName"] as? String else {
            return nil
        }
        
        let likeCount = data["likeCount"] as? Int ?? 0
        let likedBy = data["likedBy"] as? [String] ?? []

        return Post(
            id: document.documentID,
            content: content,
            timestamp: timestamp.dateValue(),
            authorName: authorName,
            authorSubtitle: authorSubtitle,
            likeCount: likeCount,
            authorID: authorID,
            profilePicName: profilePicName,
            likedBy: likedBy
        )
    }

    // Saves a new post to Firestore using the current user's profile info
    func addPost(content: String, profile: Profile) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let postData: [String: Any] = [
            "content": content,
            "timestamp": Timestamp(date: Date()),
            "authorName": profile.name,
            "authorSubtitle": profile.subtitle,
            "likeCount": 0,
            "authorID": userID,
            "profilePicName": profile.profilePicName,
            "likedBy": []
        ]

        db.collection("posts").addDocument(data: postData) { error in
            if let error = error {
                print("Error saving post: \(error.localizedDescription)")
            } else {
                print("Post saved successfully!")
            }
        }
    }
    
    // Checks if the current user has liked the post.
    // If yes removes their like, if no it adds their like
    func toggleLike(for post: Post) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let postRef = db.collection("posts").document(post.id)

        if post.likedBy.contains(currentUserID) {
            // Unlike which removes userID from likedBy and subtracts 1 from likeCount
            postRef.updateData([
                "likedBy": FieldValue.arrayRemove([currentUserID]),
                "likeCount": FieldValue.increment(Int64(-1))
            ]) { error in
                if let error = error {
                    print("Error unliking post: \(error.localizedDescription)")
                } else {
                    print("Post unliked successfully!")
                }
            }
        } else {
            // Like which adds userID to likedBy and adds 1 to likeCount
            postRef.updateData([
                "likedBy": FieldValue.arrayUnion([currentUserID]),
                "likeCount": FieldValue.increment(Int64(1))
            ]) { error in
                if let error = error {
                    print("Error liking post: \(error.localizedDescription)")
                } else {
                    print("Post liked successfully!")
                    // Makes a notification to show the author the like
                    self.createNotification(
                        type: "like",
                        postID: post.id,
                        senderUserID: currentUserID,
                        recipientUserID: post.authorID
                    )
                }
            }
        }
    }

    // Gets all the comments for post
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
                          let authorName = data["authorName"] as? String,
                          let profilePicName = data["profilePicName"] as? String else {
                        return nil
                    }
                    return Comment(
                        id: document.documentID,
                        content: content,
                        timestamp: timestamp.dateValue(),
                        authorName: authorName,
                        profilePicName: profilePicName
                    )
                } ?? []
            }
    }

    // Adds a comment to the post
    // Fetches the current user's profile info for the comment
    func addComment(to post: Post, content: String, profile: Profile) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("profiles").document(currentUserID).getDocument { snapshot, error in
            var authorName = profile.name
            var profilePic = profile.profilePicName

            if let data = snapshot?.data() {
                authorName = data["name"] as? String ?? authorName
                profilePic = data["profilePicName"] as? String ?? profilePic
            }
            
            if authorName.isEmpty { authorName = "Unknown User" }
            if profilePic.isEmpty { profilePic = "defaultProfilePic" }

            let commentData: [String: Any] = [
                "content": content,
                "timestamp": Timestamp(date: Date()),
                "authorName": authorName,
                "profilePicName": profilePic
            ]

            self.db.collection("posts")
                .document(post.id)
                .collection("comments")
                .addDocument(data: commentData) { error in
                    if let error = error {
                        print("Error adding comment: \(error.localizedDescription)")
                    } else {
                        print("Comment added successfully!")
                        // Create notification for the author about the new comment
                        self.createNotification(
                            type: "comment",
                            postID: post.id,
                            senderUserID: currentUserID,
                            recipientUserID: post.authorID
                        )
                    }
                }
        }
    }
    
    // Adds a notification document in Firestore to show the recipient about who interacted with them
    private func createNotification(type: String, postID: String, senderUserID: String, recipientUserID: String) {
        let notificationData: [String: Any] = [
            "type": type,
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
