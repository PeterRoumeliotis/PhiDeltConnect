import SwiftUI

struct CreatePostView: View {
    @State private var postContent = ""
    @ObservedObject var postManager = PostManager()
    @ObservedObject var profileManager = ProfileManager()

    var body: some View {
        VStack {
            TextField("What's on your mind?", text: $postContent)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                guard !postContent.isEmpty else { return }
                postManager.addPost(content: postContent, profile: profileManager.profile)
                postContent = ""
            }) {
                Text("Post")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Create Post")
        .onAppear {
            profileManager.fetchProfile()
        }
    }
}
