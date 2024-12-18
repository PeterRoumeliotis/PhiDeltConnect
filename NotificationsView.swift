// NotificationsView.swift
// PhiDeltConnectV2
// Peter Roumeliotis

import SwiftUI

// Shows a list of all notifications for the current user

struct NotificationsView: View {
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        NavigationView {
            List(notificationManager.notifications) { notification in
                NotificationView(notification: notification)
            }
            .navigationBarTitle("Notifications")
            .onAppear {
                // Fetch notifications when the view shows
                notificationManager.fetchNotifications()
            }
        }
    }
}

// Shows a single notification with an icon and text
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
        // Format notification
        switch notification.type {
        case "like":
            return "Your post was liked by \(notification.senderName)."
        case "comment":
            return "Your post received a new comment from \(notification.senderName)."
        case "follow":
            return "You have a new follower: \(notification.senderName)."
        default:
            return "You have a new notification from \(notification.senderName)."
        }
    }
}
