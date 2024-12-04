import SwiftUI

//Home View
struct HomeView: View {
    @ObservedObject var postManager: PostManager

    var body: some View {
        NavigationView {
            List {
                ForEach(postManager.posts) { post in
                    PostView(post: post)
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }
}

//Post View
struct PostView: View {
    var post: Post
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Post profile
            HStack {
                Image("ProfilePic")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .shadow(radius: 5)
                Text(post.profile)
                    .font(.headline)
            }
            // Post image
            if let imageName = post.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
            }
            
            // Post content
            Text(post.content)
                .font(.body)
            
            // Like and comment section
            HStack {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(post.likeCount) likes")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.blue)
                    Text("\(post.comments.count) comments")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            
            // Comments section
            VStack(alignment: .leading, spacing: 5) {
                ForEach(post.comments.prefix(3), id: \.self) { comment in
                    Text(comment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if post.comments.count > 3 {
                    Text("View all comments")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 10)
    }
}
