//  ProfileView.swift
//  PhiDeltConnectV2
//  PeterRoumeliotis

import SwiftUI

// PROFILE TAB
struct ProfileView: View {
    @State private var showYearAlert = false
    @State private var yearsInFraternity = 1 
    @State private var joinDate = "March 2023" 

    var body: some View {
        NavigationView {
            ScrollView {
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

                    // Name and Shield Button
                    HStack(alignment: .center, spacing: 10) {
                        Text("Peter Roumeliotis")
                            .font(.title)
                            .padding(.bottom, 2)

                        Button(action: {
                            showYearAlert = true
                        }) {
                            ZStack {
                                // Shield Icon
                                Image(systemName: "shield.fill")
                                    .resizable()
                                    .frame(width: 30, height: 35)
                                    .foregroundColor(Color.blue)

                                // Number of Years Text
                                Text("\(yearsInFraternity)")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .bold()
                            }
                            .accessibility(label: Text("\(yearsInFraternity) years in fraternity"))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 2)
                        .alert(isPresented: $showYearAlert) {
                            Alert(
                                title: Text("Fraternity Membership"),
                                message: Text("Joined in \(joinDate)"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }

                    // Student position
                    Text("Computer Science Student at St. John's University")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)

                    Divider()

                    // About and Experience Sections
                    VStack(alignment: .leading) {
                        Text("About")
                            .font(.headline)
                            .padding(.bottom, 5)
                        Text("I am currently studying Computer Science at St. John's University. Eventually I would like to either have some form of job in Software Engineering or Cyber Security. I have had a passion for computers and the way they work since I was young. I am a hard worker and have done an excellent job in all of my past experiences. I exemplify leadership qualities as seen in my position as treasurer for my fraternity. Currently I am looking for an internship to excel in and learn as much as I can about my future career. I am skilled in Java, Javascript, Python, C++, and SQL.")
                            .font(.body)
                            .padding(.bottom, 20)
                        Text("Experience")
                            .font(.headline)
                            .padding(.bottom, 5)
                        Text("- Cyber Security Intern at NY Metro InfraGard\n- Software Engineer Intern at CTS Logistics")
                            .font(.body)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Profile", displayMode: .inline)
        }
    }
}
