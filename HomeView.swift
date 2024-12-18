//  Homeview.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import SwiftUI

// The Home tab shows all posts and lets you search for posts
// The For You tab shows posts for you based on word from looking for work and your subtitle in the user's profile

struct HomeView: View {
    @ObservedObject var postManager = PostManager()
    @ObservedObject var profileManager = ProfileManager()
    
    @State private var isSearching = false
    @State private var searchText = ""
    @State private var selectedTab = 0 // 0 = Home 1 = For You

    // For when you are searching only shows text you searched for
    private var filteredPosts: [Post] {
        if searchText.isEmpty {
            return postManager.posts
        } else {
            return postManager.posts.filter { $0.content.lowercased().contains(searchText.lowercased()) }
        }
    }

    // Takes the first word from the user's subtitle as a for you keyword
    private var firstWordFromSubtitle: String {
        return profileManager.profile.subtitle
            .split(separator: " ")
            .first.map { String($0).lowercased() } ?? ""
    }

    // Takes the first word from the user's lookingForWorkTitle as a for you keyword
    private var firstWordFromLookingForWorkTitle: String {
        return profileManager.profile.lookingForWorkTitle
            .split(separator: " ")
            .first.map { String($0).lowercased() } ?? ""
    }

    // For You posts: If either the first word from subtitle or the first word from lookingForWorkTitle
    // is anywhere in the post content, it shows the post. Posts are sorted chronologically.
    private var forYouPosts: [Post] {
        // If both words are empty, no filtering is possible
        if firstWordFromSubtitle.isEmpty && firstWordFromLookingForWorkTitle.isEmpty {
            return []
        }

        let posts = postManager.posts.filter { post in
            let content = post.content.lowercased()
            let matchesSubtitleWord = !firstWordFromSubtitle.isEmpty && content.contains(firstWordFromSubtitle)
            let matchesWorkWord = !firstWordFromLookingForWorkTitle.isEmpty && content.contains(firstWordFromLookingForWorkTitle)
            return matchesSubtitleWord || matchesWorkWord
        }
        return posts.sorted(by: { $0.timestamp < $1.timestamp })
    }

    var body: some View {
        NavigationView {
            VStack {
                // Control for switching between Home and For You tabs
                Picker(selection: $selectedTab, label: Text("Tabs")) {
                    Text("Home").tag(0)
                    Text("For You").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if isSearching && selectedTab == 0 {
                    HStack {
                        TextField("Search posts or profiles...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                        
                        Button(action: {
                            withAnimation {
                                isSearching = false
                                searchText = ""
                            }
                        }) {
                            Text("Cancel")
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top)
                }

                if selectedTab == 0 {
                    // Home tab
                    List {
                        // If searching and profiles found, show them
                        if isSearching && !searchText.isEmpty && !filteredProfiles.isEmpty {
                            Section(header: Text("Profiles")) {
                                ForEach(filteredProfiles) { profileEntry in
                                    NavigationLink(destination: ProfileView(userID: profileEntry.id)) {
                                        HStack(spacing: 15) {
                                            Image(profileEntry.profile.profilePicName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                            
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(profileEntry.profile.name)
                                                    .font(.headline)
                                                    .bold()
                                                Text(profileEntry.profile.subtitle)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.vertical, 5)
                                    }
                                }
                            }
                        }
                        
                        // Posts Section on Home tab
                        Section(header: Text("Posts")) {
                            ForEach(filteredPosts) { post in
                                NavigationLink(destination: PostDetailView(
                                    postManager: postManager,
                                    profileManager: profileManager,
                                    post: post
                                )) {
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
                                        }

                                        Text(post.content)
                                            .font(.body)
                                            .padding(.top, 5)
                                    }
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                    }
                } else {
                    // For You tab
                    List {
                        // If no posts are found based on the words
                        if firstWordFromSubtitle.isEmpty && firstWordFromLookingForWorkTitle.isEmpty {
                            Text("Nothing found for you.")
                                .foregroundColor(.gray)
                        } else {
                            // There are matching posts with the words
                            ForEach(forYouPosts) { post in
                                NavigationLink(destination: PostDetailView(
                                    postManager: postManager,
                                    profileManager: profileManager,
                                    post: post
                                )) {
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
                                        }

                                        Text(post.content)
                                            .font(.body)
                                            .padding(.top, 5)
                                    }
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(selectedTab == 0 ? "Home" : "For You")
            // The search icon appears on the Home tab
            .navigationBarItems(trailing: selectedTab == 0 ? Button(action: {
                withAnimation {
                    isSearching.toggle()
                    if !isSearching {
                        searchText = ""
                    }
                }
            }) {
                Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                    .foregroundColor(.blue)
            } : nil)
            //Data is fetched right away with .task instead of .onAppear
            .task {
                // Fetch profile, posts, and all profiles for search
                profileManager.fetchProfile()
                postManager.fetchPosts()
                profileManager.fetchAllProfiles()
            }
        }
    }

    // Profiles shown if user searches by name on the Home tab
    private var filteredProfiles: [ProfileEntry] {
        if searchText.isEmpty {
            return []
        } else {
            return profileManager.allProfiles.filter { $0.profile.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    // Format the Date to a string
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
