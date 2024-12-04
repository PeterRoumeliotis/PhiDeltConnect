//  NotificationsView.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import SwiftUI

//Notifications View
struct NotificationsView: View {
    var body: some View {
        NavigationView {
            List {
                // sample notifications
                ForEach(1..<10) { index in
                    NotificationView(notificationText: "You have a new connection request from Member \(index).")
                }
            }
            .navigationBarTitle("Notifications")
        }
    }
}

struct NotificationView: View {
    var notificationText: String
    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundColor(.blue)
            Text(notificationText)
        }
        .padding(.vertical, 5)
    }
}

