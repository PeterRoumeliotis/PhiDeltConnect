//  ProfileView.swift
//  PhiDeltConnectV2
//  PeterRoumeliotis

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var profileManager = ProfileManager()
    @EnvironmentObject var session: SessionManager
    @State private var isEditing = false
    @State private var showYearSheet = false // Use sheet instead of Alert
    @State private var tempYearsInFraternity = 0 // Temporary variable for editing

    var body: some View {
        NavigationView {
            VStack {
                // Profile Image
                Image("ProfilePic")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .shadow(radius: 5)
                    .padding()

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

                    // Badge Icon
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
                                .foregroundColor(Color.blue) // Always blue, no tint

                            Text("\(profileManager.profile.yearsInFraternity)")
                                .font(.title3)
                                .foregroundColor(.white)
                                .bold()
                        }
                        .accessibility(label: Text("\(profileManager.profile.yearsInFraternity) years in fraternity"))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onTapGesture {
                        //Try to fix this so that it shows the years when pressed not in edit mode
                        if !isEditing {
                            showYearSheet = true // Show sheet to display the years in read-only mode
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

                // Editable About Section
                Text("About")
                    .font(.headline)
                if isEditing {
                    TextEditor(text: $profileManager.profile.about)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                } else {
                    Text(profileManager.profile.about)
                        .font(.body)
                }

                Divider()

                // Editable Experience Section
                Text("Experience")
                    .font(.headline)
                if isEditing {
                    TextEditor(text: $profileManager.profile.experience)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                } else {
                    Text(profileManager.profile.experience)
                        .font(.body)
                }

                Spacer()
            }
            .padding()
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
            }
        }
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
