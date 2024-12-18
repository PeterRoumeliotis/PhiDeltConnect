//  LoginView.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import SwiftUI
import Firebase
import FirebaseAuth

// Lets a user enter their email and password and sign in using Firebase Auth.
// If login works, SessionManager.isLoggedIn is set to true, bringing you to the main app

struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    @State private var email = ""
    @State private var password = ""
    @State var showError: Bool = false
    @State var errorMessage: String = ""

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
                loginUser() // Try to login
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
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    // Uses Firebase Auth's signIn method to authenticate
    func loginUser() {
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("User Found")
                session.isLoggedIn = true // Go to main app on success
            } catch {
                await setError(error)
            }
        }
    }
    
    // Error messages
    func setError(_ error: Error) async {
        await MainActor.run {
            let authError = error as NSError
            switch authError.code {
            case AuthErrorCode.invalidEmail.rawValue:
                errorMessage = "The email address is invalid. Please try again."
            case AuthErrorCode.wrongPassword.rawValue:
                errorMessage = "The password is incorrect. Please try again."
            case AuthErrorCode.userNotFound.rawValue:
                errorMessage = "No user found with this email. Please check your login."
            default:
                errorMessage = "Invalid login. Please check your email and password."
            }
            showError.toggle()
        }
    }
}
