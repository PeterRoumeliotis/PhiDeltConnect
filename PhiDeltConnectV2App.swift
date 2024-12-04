//  PhiDeltConnectV2App.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import SwiftUI

//Start
@main
struct PhiDeltConnect: App {
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

//Session Manager
class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
}
