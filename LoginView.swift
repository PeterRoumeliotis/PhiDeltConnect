//  LoginView.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import SwiftUI

//Login View
struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        VStack {
            Spacer()
            Image("LoginLogo")
                .resizable()
                .scaledToFit()
            Spacer()
            TextField("Email", text: $email)
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                // Implement login logic
                session.isLoggedIn = true
            }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            Spacer()
        }
        .padding()
    }
}
