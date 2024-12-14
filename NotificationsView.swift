import SwiftUI

//Notifications View
struct NotificationsView: View {
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        NavigationView {
            List(notificationManager.notifications) { notification in
                NotificationView(notification: notification)
            }
            .navigationBarTitle("Notifications")
            .onAppear {
                notificationManager.fetchNotifications()
            }
        }
    }
}

struct NotificationView: View {
    var notification: NotificationItem
    
    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundColor(.blue)
            Text(formatNotificationText())
        }
        .padding(.vertical, 5)
    }
    
    private func formatNotificationText() -> String {
        // Now using senderName instead of senderUserID
        switch notification.type {
        case "like":
            return "Your post was liked by \(notification.senderName)."
        case "comment":
            return "Your post received a new comment from \(notification.senderName)."
        default:
            return "You have a new notification from \(notification.senderName)."
        }
    }
}

