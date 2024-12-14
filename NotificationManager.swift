import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class NotificationManager: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func fetchNotifications() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No user logged in, cannot fetch notifications.")
            return
        }
        
        listener?.remove()
        listener = db.collection("notifications")
            .whereField("recipientUserID", isEqualTo: currentUserID)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")
                    return
                }

                var tempNotifications: [NotificationItem] = []
                
                snapshot?.documents.forEach { doc in
                    let data = doc.data()
                    guard let type = data["type"] as? String,
                          let postID = data["postID"] as? String,
                          let senderUserID = data["senderUserID"] as? String,
                          let recipientUserID = data["recipientUserID"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return
                    }
                    
                    let notification = NotificationItem(
                        id: doc.documentID,
                        type: type,
                        postID: postID,
                        senderUserID: senderUserID,
                        recipientUserID: recipientUserID,
                        timestamp: timestamp.dateValue()
                    )
                    tempNotifications.append(notification)
                }
                
                // Fetch sender names after we've got all notifications
                self.fetchSenderNames(for: tempNotifications) { updatedNotifications in
                    DispatchQueue.main.async {
                        self.notifications = updatedNotifications
                    }
                }
            }
    }
    
    private func fetchSenderNames(for notifications: [NotificationItem], completion: @escaping ([NotificationItem]) -> Void) {
        let group = DispatchGroup()
        var updatedNotifications = notifications
        
        for i in 0..<updatedNotifications.count {
            let senderUserID = updatedNotifications[i].senderUserID
            group.enter()
            
            fetchUserName(for: senderUserID) { name in
                updatedNotifications[i].senderName = name
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(updatedNotifications)
        }
    }
    
    private func fetchUserName(for userID: String, completion: @escaping (String) -> Void) {
        db.collection("profiles").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user name: \(error.localizedDescription)")
                completion("Unknown User")
                return
            }
            
            let name = snapshot?.data()?["name"] as? String ?? "Unknown User"
            completion(name)
        }
    }
}
