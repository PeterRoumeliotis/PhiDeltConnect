//  LoginView.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import SwiftUI
import Firebase
import FirebaseAuth

//Login View
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
                loginUser()
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
    
    func loginUser(){
        Task{
            do{
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("User Found")
                session.isLoggedIn = true
            } catch {
                await setError(error)
            }
            
        }
    }
    
    func setError(_ error: Error) async {
        await MainActor.run {
            let authError = error as NSError
            switch authError.code {
            case AuthErrorCode.invalidEmail.rawValue:
                errorMessage = "The email address is invalid. Please try again."
            case AuthErrorCode.wrongPassword.rawValue:
                errorMessage = "The password is incorrect. Please try again."
            case AuthErrorCode.userNotFound.rawValue:
                errorMessage = "No user found with this email. Please check your credentials."
            default:
                errorMessage = "Invalid login. Please check your email and password."
            }
            showError.toggle()
        }
    }

    
}

