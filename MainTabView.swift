// MainTabView.swift
// PhiDeltConnectV2
// Peter Roumeliotis

import SwiftUI

// Tab view displayed after login.
// Home, Notifications, Create Post, Chapter, and Profile.

struct MainTabView: View {
    // PostManager instance for consistency
    @StateObject private var postManager = PostManager() // Shared PostManager

    var body: some View {
        TabView {
            // Home Tab
            HomeView(postManager: postManager)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            // Notifications Tab
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notifications")
                }
            
            // Create Post Tab
            CreatePostView(postManager: postManager)
                .tabItem {
                    Image(systemName: "plus.square")
                    Text("Create Post")
                }
            
            // Chapter Tab
            ChapterView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Chapter")
                }
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}
