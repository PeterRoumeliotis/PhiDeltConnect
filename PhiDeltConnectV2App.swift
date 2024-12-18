//  PhiDeltConnectV2App.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import SwiftUI
import Firebase

// Uses a SessionManager to know if the user is logged in.
// If user is logged in shows MainTabView, if not then shows LoginView.
@main
struct PhiDeltConnect: App {
    init() {
        // Configure Firebase when the app starts
        FirebaseApp.configure()
    }
    
    @StateObject var session = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                MainTabView()
                    .environmentObject(session)
            } else {
                LoginView()
                    .environmentObject(session)
            }
        }
    }
}

// SessionManager tracks whether the user is logged in
class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
}
