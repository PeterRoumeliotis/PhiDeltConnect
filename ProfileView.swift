// ProfileView.swift
// PhiDeltConnectV2
// Peter Roumeliotis

import SwiftUI
import FirebaseAuth

// Shows the current user's profile
// The user can edit their profile and see their posts

struct ProfileView: View {
    @StateObject private var profileManager: ProfileManager
    @StateObject private var userPostsManager = PostManager()
    @EnvironmentObject var session: SessionManager
    @State private var isEditing = false
    @State private var showYearSheet = false
    @State private var tempYearsInFraternity = 0

    // userID shows which user's profile is displayed.
    // If nil, it is the current logged-in user's profile.
    var userID: String?

    init(userID: String? = nil) {
        _profileManager = StateObject(wrappedValue: ProfileManager(userID: userID))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image("\(profileManager.profile.profilePicName)")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .shadow(radius: 5)
                        .padding(.top)

                    HStack(alignment: .center, spacing: 10) {
                        // Name, editable if current user's profile
                        if isCurrentUserProfile {
                            if isEditing {
                                TextField("Name", text: $profileManager.profile.name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                Text(profileManager.profile.name)
                                    .font(.title)
                                    .bold()
                            }
                        } else {
                            Text(profileManager.profile.name)
                                .font(.title)
                                .bold()
                        }

                        // Years in fraternity badge
                        Button(action: {
                            if isEditing {
                                tempYearsInFraternity = profileManager.profile.yearsInFraternity
                                showYearSheet = true
                            }
                        }) {
                            ZStack {
                                Image(systemName: "shield.fill")
                                    .resizable()
                                    .frame(width: 30, height: 35)
                                    .foregroundColor(Color.blue)

                                Text("\(profileManager.profile.yearsInFraternity)")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .bold()
                            }
                            .accessibility(label: Text("\(profileManager.profile.yearsInFraternity) years in fraternity"))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onTapGesture {
                            // Show sheet to edit years
                            if !isEditing && isCurrentUserProfile {
                                showYearSheet = true
                            }
                        }
                    }

                    // Subtitle field
                    if isCurrentUserProfile {
                        if isEditing {
                            TextField("Subtitle", text: $profileManager.profile.subtitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(profileManager.profile.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text(profileManager.profile.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Divider()

                    // About section
                    Text("About")
                        .font(.headline)
                    if isCurrentUserProfile && isEditing {
                        TextEditor(text: $profileManager.profile.about)
                            .frame(minHeight: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    } else {
                        Text(profileManager.profile.about)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()

                    // Experience section
                    Text("Experience")
                        .font(.headline)
                    if isCurrentUserProfile && isEditing {
                        TextEditor(text: $profileManager.profile.experience)
                            .frame(minHeight: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    } else {
                        Text(profileManager.profile.experience)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Divider()
                    
                    // Looking for Work section
                    Text("Looking for Work")
                        .font(.headline)
                    if isCurrentUserProfile && isEditing {
                        TextField("Job Title You're Looking For", text: $profileManager.profile.lookingForWorkTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        if profileManager.profile.lookingForWorkTitle.isEmpty {
                            Text("Not specified.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            Text(profileManager.profile.lookingForWorkTitle)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Divider()

                    // Followers section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Followers (\(profileManager.profile.followers.count))")
                            .font(.headline)

                        if profileManager.followerNames.isEmpty {
                            Text("No followers yet.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        } else {
                            ForEach(profileManager.followerNames, id: \.self) { followerName in
                                Text(followerName)
                                    .font(.body)
                            }
                        }
                    }

                    Divider()

                    // If viewing another user's profile, show follow/unfollow button
                    if !isCurrentUserProfile {
                        Button(action: {
                            toggleFollow()
                        }) {
                            Text(profileManager.isCurrentUserFollowing ? "Unfollow" : "Follow")
                                .foregroundColor(.white)
                                .padding()
                                .background(profileManager.isCurrentUserFollowing ? Color.red : Color.blue)
                                .cornerRadius(8)
                        }
                    }

                    // If this is the current user's profile show their posts
                    if isCurrentUserProfile {
                        Divider()

                        Text("Your Posts")
                            .font(.headline)

                        ForEach(userPostsManager.posts) { post in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top, spacing: 10) {
                                    Image("\(post.profilePicName)")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(post.authorName)
                                            .font(.headline)
                                            .bold()

                                        Text(post.authorSubtitle)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                        Text(formatDate(post.timestamp))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    // Like button and count for user's own posts
                                    VStack(spacing: 5) {
                                        Button(action: {
                                            userPostsManager.toggleLike(for: post)
                                        }) {
                                            Image(systemName: "heart")
                                                .font(.title3)
                                                .foregroundColor(post.likedBy.contains(Auth.auth().currentUser?.uid ?? "") ? .red : .blue)
                                        }
                                        Text("\(post.likeCount)")
                                            .font(.caption)
                                    }
                                }

                                Text(post.content)
                                    .font(.body)
                                    .padding(.top, 5)

                                // Goes to the post detail view for comments
                                NavigationLink(destination: PostDetailView(postManager: userPostsManager, profileManager: profileManager, post: post)) {
                                    Text("View Comments")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 10)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarItems(
                leading: Button(action: logOutUser) {
                    Image(systemName: "arrow.backward.square")
                    Text("Logout")
                        .foregroundColor(.red)
                },
                trailing: isCurrentUserProfile ? Button(action: {
                    // Toggle editing mode
                    if isEditing {
                        profileManager.saveProfile()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit")
                } : nil
            )
            .sheet(isPresented: $showYearSheet) {
                VStack {
                    Text(isEditing ? "Edit Years in Fraternity" : "Fraternity Membership")
                        .font(.headline)
                        .padding()

                    if isEditing {
                        TextField("Years", value: $tempYearsInFraternity, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    } else {
                        Text("You have been in the fraternity for \(profileManager.profile.yearsInFraternity) years.")
                            .font(.body)
                            .padding()
                    }

                    Button("Save") {
                        if isEditing {
                            profileManager.profile.yearsInFraternity = tempYearsInFraternity
                        }
                        showYearSheet = false
                    }
                    .padding()
                }
                .padding()
            }
            .onAppear {
                profileManager.fetchProfile()
                if let currentUserID = Auth.auth().currentUser?.uid {
                    // If viewing own profile, fetch the user's own posts
                    if isCurrentUserProfile {
                        userPostsManager.fetchPostsByUserID(userID: currentUserID)
                    }
                }
            }
        }
    }

    private var isCurrentUserProfile: Bool {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return false }
        return userID == nil || userID == currentUserID
    }

    private func toggleFollow() {
        guard let viewedUserID = profileManager.userID else { return }
        profileManager.toggleFollowUser(targetUserID: viewedUserID)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Log out the current user
    private func logOutUser() {
        do {
            try Auth.auth().signOut()
            print("User logged out successfully.")
            session.isLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}
