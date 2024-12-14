import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var profileManager = ProfileManager()
    @StateObject private var userPostsManager = PostManager()
    @EnvironmentObject var session: SessionManager
    @State private var isEditing = false
    @State private var showYearSheet = false
    @State private var tempYearsInFraternity = 0

    
    private var profileImageName: String {
           guard let userID = Auth.auth().currentUser?.uid else { return "ProfilePicDefault" }

           switch userID {
           case "jDCF6QUycDQDMP5m9Y8UVF5oOfy1":
               return "ProfilePic"
           case "gO2kqyfqA3NeNDEIm6sy8I7N7mE2":
               return "ProfilePicArafat"
           default:
               return "ProfilePicDefault" // fallback image
           }
       }
    
    var body: some View {
        NavigationView {
            ScrollView { // Use ScrollView to show full text and user posts
                VStack(alignment: .leading, spacing: 20) {
                    // Profile Image
                    Image(profileImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .shadow(radius: 5)
                        .padding(.top)

                    HStack(alignment: .center, spacing: 10) {
                        // Editable Name
                        if isEditing {
                            TextField("Name", text: $profileManager.profile.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(profileManager.profile.name)
                                .font(.title)
                                .bold()
                        }

                        // Badge Icon (Years in fraternity)
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
                            if !isEditing {
                                showYearSheet = true
                            }
                        }
                    }

                    // Editable Subtitle
                    if isEditing {
                        TextField("Subtitle", text: $profileManager.profile.subtitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(profileManager.profile.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Divider()

                    // About Section
                    Text("About")
                        .font(.headline)
                    if isEditing {
                        TextEditor(text: $profileManager.profile.about)
                            .frame(minHeight: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    } else {
                        Text(profileManager.profile.about)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()

                    // Experience Section
                    Text("Experience")
                        .font(.headline)
                    if isEditing {
                        TextEditor(text: $profileManager.profile.experience)
                            .frame(minHeight: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    } else {
                        Text(profileManager.profile.experience)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()

                    // User's own posts
                    Text("Your Posts")
                        .font(.headline)

                    // Display posts by the currently logged-in user
                    ForEach(userPostsManager.posts) { post in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 10) {
                                Image("ProfilePic")
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

                                // Like button and count
                                VStack(spacing: 5) {
                                    Button(action: {
                                        userPostsManager.incrementLike(for: post)
                                    }) {
                                        Image(systemName: "heart")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                    }
                                    Text("\(post.likeCount)")
                                        .font(.caption)
                                }
                            }

                            Text(post.content)
                                .font(.body)
                                .padding(.top, 5)

                            NavigationLink(destination: PostDetailView(postManager: userPostsManager, profileManager: profileManager, post: post)) {
                                Text("View Comments")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 10)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarItems(
                leading: Button(action: logOutUser) {
                    Image(systemName: "arrow.backward.square") // Logout Icon
                    Text("Logout")
                        .foregroundColor(.red)
                },
                trailing: Button(action: {
                    if isEditing {
                        profileManager.saveProfile() // Save when editing finishes
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit")
                }
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
                if let userID = Auth.auth().currentUser?.uid {
                    userPostsManager.fetchPostsByUserID(userID: userID)
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Logout Function
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
