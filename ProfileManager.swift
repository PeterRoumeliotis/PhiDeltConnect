// ProfileManager.swift
// PhiDeltConnectV2
// Peter Roumeliotis

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

// Combines a userID with a Profile model for searching.
struct ProfileEntry: Identifiable {
    var id: String
    var profile: Profile
}

// Manages fetching and updating user profiles from Firestore
// It also has follow/unfollow logic and fetching all profiles for search

class ProfileManager: ObservableObject {
    @Published var profile = Profile(name: "", subtitle: "", about: "", experience: "", yearsInFraternity: 0, profilePicName: "", followers: [], lookingForWorkTitle: "")
    @Published var followerNames: [String] = []
    @Published var allProfiles: [ProfileEntry] = []
    
    private let db = Firestore.firestore()
    private let currentUserID: String? = Auth.auth().currentUser?.uid

    let userID: String?

    init(userID: String? = nil) {
        // If no userID is there, makes it the current logged-in user
        self.userID = userID ?? Auth.auth().currentUser?.uid
    }

    var isCurrentUserFollowing: Bool {
        guard let currentID = currentUserID else { return false }
        return profile.followers.contains(currentID)
    }

    // Fetches the profile of userID from Firestore and updates it on the phone
    func fetchProfile() {
        guard let userID = userID else { return }

        db.collection("profiles").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching profile: \(error.localizedDescription)")
                return
            }
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.profile.name = data["name"] as? String ?? ""
                    self.profile.subtitle = data["subtitle"] as? String ?? ""
                    self.profile.about = data["about"] as? String ?? ""
                    self.profile.experience = data["experience"] as? String ?? ""
                    self.profile.yearsInFraternity = data["yearsInFraternity"] as? Int ?? 0
                    self.profile.profilePicName = data["profilePicName"] as? String ?? ""
                    self.profile.followers = data["followers"] as? [String] ?? []
                    self.profile.lookingForWorkTitle = data["lookingForWorkTitle"] as? String ?? ""
                    self.fetchFollowerNames()
                }
            }
        }
    }

    // Writes the current profile data back to Firestore.
    func saveProfile() {
        guard let userID = userID else { return }

        let profileData: [String: Any] = [
            "name": profile.name,
            "subtitle": profile.subtitle,
            "about": profile.about,
            "experience": profile.experience,
            "yearsInFraternity": profile.yearsInFraternity,
            "profilePicName": profile.profilePicName,
            "followers": profile.followers,
            "lookingForWorkTitle": profile.lookingForWorkTitle
        ]

        db.collection("profiles").document(userID).setData(profileData) { error in
            if let error = error {
                print("Error saving profile: \(error.localizedDescription)")
            } else {
                print("Profile saved successfully!")
            }
        }
    }

    // Adds or removes the current user from the other user's followers list
    // Also sends a follow notification
    func toggleFollowUser(targetUserID: String) {
        guard let currentUserID = currentUserID else { return }

        db.collection("profiles").document(targetUserID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching target user's profile for follow/unfollow: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else { return }
            var followers = data["followers"] as? [String] ?? []

            if followers.contains(currentUserID) {
                // Unfollow
                followers.removeAll { $0 == currentUserID }
            } else {
                // Follow
                followers.append(currentUserID)
                self.sendFollowNotification(to: targetUserID)
            }

            // Update the other user's followers in Firestore
            self.db.collection("profiles").document(targetUserID).updateData(["followers": followers]) { err in
                if let err = err {
                    print("Error updating followers: \(err.localizedDescription)")
                } else {
                    print("Followers updated successfully!")
                    // If on current user's profile, update followers
                    if targetUserID == self.userID {
                        DispatchQueue.main.async {
                            self.profile.followers = followers
                            self.fetchFollowerNames()
                        }
                    }
                }
            }
        }
    }

    // Fetches the names of all followers for the profile you are looking at
    private func fetchFollowerNames() {
        followerNames = []
        let group = DispatchGroup()

        for followerID in profile.followers {
            group.enter()
            db.collection("profiles").document(followerID).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching follower name: \(error.localizedDescription)")
                    group.leave()
                    return
                }
                let name = snapshot?.data()?["name"] as? String ?? "Unknown User"
                self.followerNames.append(name)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            // All follower names are fetched
        }
    }

    // Makes a follow notification for the other user.
    private func sendFollowNotification(to userID: String) {
        guard let currentUserID = currentUserID else { return }

        let notificationData: [String: Any] = [
            "type": "follow",
            "postID": "",
            "senderUserID": currentUserID,
            "recipientUserID": userID,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("notifications").addDocument(data: notificationData) { error in
            if let error = error {
                print("Error sending follow notification: \(error.localizedDescription)")
            } else {
                print("Follow notification sent successfully!")
            }
        }
    }
    
    // Fetches every user profile, used for search in HomeView
    func fetchAllProfiles() {
        db.collection("profiles").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching all profiles: \(error.localizedDescription)")
                return
            }
            var tempProfiles: [ProfileEntry] = []
            snapshot?.documents.forEach { doc in
                let data = doc.data()
                let profile = Profile(
                    name: data["name"] as? String ?? "",
                    subtitle: data["subtitle"] as? String ?? "",
                    about: data["about"] as? String ?? "",
                    experience: data["experience"] as? String ?? "",
                    yearsInFraternity: data["yearsInFraternity"] as? Int ?? 0,
                    profilePicName: data["profilePicName"] as? String ?? "",
                    followers: data["followers"] as? [String] ?? [],
                    lookingForWorkTitle: data["lookingForWorkTitle"] as? String ?? ""
                )
                tempProfiles.append(ProfileEntry(id: doc.documentID, profile: profile))
            }
            DispatchQueue.main.async {
                self.allProfiles = tempProfiles
            }
        }
    }
}
