import Foundation
import Firebase
import FirebaseFirestore

class PostManager: ObservableObject {
    @Published var posts: [Post] = []
    private let db = Firestore.firestore()

    // Fetch posts
    func fetchPosts() {
        db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    return
                }

                self.posts = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard let content = data["content"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp,
                          let authorName = data["authorName"] as? String,
                          let authorSubtitle = data["authorSubtitle"] as? String else {
                        return nil
                    }
                    return Post(
                        id: document.documentID,
                        content: content,
                        timestamp: timestamp.dateValue(),
                        authorName: authorName,
                        authorSubtitle: authorSubtitle
                    )
                } ?? []
            }
    }

    // Save post with raw dictionary
    func addPost(content: String, profile: Profile) {
        let postData: [String: Any] = [
            "content": content,
            "timestamp": Timestamp(date: Date()),
            "authorName": profile.name,
            "authorSubtitle": profile.subtitle
        ]

        db.collection("posts").addDocument(data: postData) { error in
            if let error = error {
                print("Error saving post: \(error.localizedDescription)")
            } else {
                print("Post saved successfully!")
            }
        }
    }
}
