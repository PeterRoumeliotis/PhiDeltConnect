import SwiftUI

//Create Post View
struct CreatePostView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var postManager: PostManager

    @State private var profile: String = ""
    @State private var content: String = ""
    @State private var imageName: String = ""
    @State private var likeCount: Int = 0
    @State private var comments: [String] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Post Details")) {
                    TextField("Profile", text: $profile)
                    TextField("Content", text: $content)
                }

                Section(header: Text("Image Details (Optional)")) {
                    TextField("Image Name", text: $imageName)
                }

                Section(header: Text("Likes")) {
                    Stepper("Likes: \(likeCount)", value: $likeCount, in: 0...1000)
                }

                Section(header: Text("Comments")) {
                    Button("Add Comment") {
                        comments.append("Sample Comment \(comments.count + 1)")
                    }
                    ForEach(comments, id: \.self) { comment in
                        Text(comment)
                    }
                }
            }
            .navigationBarTitle("Create Post", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let newPost = Post(
                        profile: profile,
                        content: content,
                        imageName: imageName.isEmpty ? nil : imageName,
                        likeCount: likeCount,
                        comments: comments
                    )
                    postManager.addPost(newPost)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(profile.isEmpty || content.isEmpty)
            )
        }
    }
}
