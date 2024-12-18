# PhiDeltConnect
Phi Delta Theta LinkedIn App

----------------------------------------------------------------------------------------------------------------------------------------

Peter Roumeliotis
PhiDeltConnect Documentation

Overview

The PhiDeltConnect application leverages SwiftUI for its user interface and Google’s Firebase platform (in particular, Firestore and Firebase Authentication) for backend services. The app enables users to create accounts (or log in), view and create posts, follow other users, view notifications, and customize their profile information. It provides several core functionalities including a Home feed, a "For You" feed that personalizes content based on user preferences, notifications for likes/comments/follows, and a Chapter view that loads external content via a WebView.

Firebase Integration
The application uses Firebase in several key ways:

Firebase Authentication (Auth):
Used to handle user login, logout, and identity. LoginView communicates with Firebase Auth to verify user credentials. Upon successful authentication, a SessionManager toggles the state (isLoggedIn) to show the main interface.

Cloud Firestore:
Used as a NoSQL database to store user profiles (profiles collection), user posts (posts collection), comments (comments subcollection within posts), and notifications (notifications collection).

Profiles: 
Documents keyed by userID containing fields like name, subtitle, lookingForWorkTitle, followers, etc.

Posts: 
Documents keyed by a Firestore-generated ID, each containing content, timestamp, authorName, likeCount, etc.

Comments: Stored as a subcollection under each post’s document, keyed by a Firestore-generated comment ID, containing content, timestamp, and author info.

Notifications: Each notification document includes fields for type, postID, senderUserID, recipientUserID, and timestamp.

The app updates UI by using Firestore’s snapshot listeners (addSnapshotListener) to provide real-time updates to posts, comments, and notifications.

Classes and Their Responsibilities

1. SessionManager (ObservableObject)
Functionality: Manages the user’s logged-in state.
Works With:
LoginView calls Auth.auth().signIn(). On success, SessionManager.isLoggedIn is toggled to true.
PhiDeltConnect app uses SessionManager to decide whether to show MainTabView (if logged in) or LoginView (if not).

2. LoginView (View)
Functionality: Provides a user interface for logging in.
Works With:
Uses Firebase Auth to verify credentials.
On successful login, updates SessionManager to display main content.

3. MainTabView (View)
Functionality: Displays the main tab interface after the user logs in, containing multiple tabs: Home, Notifications, Create Post, Chapter, and Profile.
Works With:
Creates and holds a PostManager instance shared across the home feed and create post screens.
Shows HomeView, NotificationsView, CreatePostView, ChapterView, and ProfileView as tabs.

4. Profile (Model Struct)
Fields: name, subtitle, about, experience, yearsInFraternity, profilePicName, followers, lookingForWorkTitle.
Functionality: Represents user profile data fetched from Firestore and displayed in ProfileView.

5. ProfileManager (ObservableObject)
Functionality: Handles fetching, saving, and managing profile data from the Firestore profiles collection. It also handles follow/unfollow logic.
Key Methods:
fetchProfile(): Retrieves the currently viewed user’s profile from Firestore.
saveProfile(): Saves edited profile data back to Firestore.
toggleFollowUser(targetUserID:): Follows or unfollows a user by updating their followers array in Firestore.
fetchAllProfiles(): Fetches all user profiles to enable searching in HomeView.
Works With:
ProfileView displays and edits profile data using ProfileManager.
HomeView uses allProfiles from ProfileManager for search functionality.
PostManager uses Profile info (like profilePicName) when adding posts or comments.

6. Post (Model Struct)
Fields: content, timestamp, authorName, likeCount, authorID, profilePicName, likedBy.
Functionality: Represents a single post and its associated metadata.

7. PostManager (ObservableObject)
Functionality: Manages fetching posts and comments from Firestore, adding new posts, toggling likes, and adding comments.
Key Methods:
fetchPosts() / fetchPostsByUserID(userID:): Retrieves posts from Firestore, either globally or filtered by a specific author.
addPost(content:profile:): Creates a new post document in Firestore.
toggleLike(for:): Adds or removes the current user’s ID from likedBy, updates likeCount in Firestore, and sends a like notification.
fetchComments(for:): Fetches comments from the comments subcollection of a given post.
addComment(to:content:profile:): Adds a comment to a post’s comments subcollection, and sends a comment notification.
Works With:
HomeView and PostDetailView to display and interact with posts.
ProfileView to display the user’s own posts.
CreatePostView to add new posts.

8. HomeView (View)
Functionality: The main feed view showing all posts and providing search capabilities. Also has a "For You" tab that personalizes content based on the user’s profile subtitle and lookingForWorkTitle.
Works With:
Uses PostManager to get the feed of posts.
Uses ProfileManager to search for profiles and fetch user preferences (such as subtitle and lookingForWorkTitle) to filter the "For You" content.

9. CreatePostView (View)
Functionality: Provides a UI for creating a new post.
Works With:
Calls postManager.addPost(content:profile:) to upload a new post to Firestore.
Fetches current user’s Profile from ProfileManager so the post includes the correct author info.

10. PostDetailView (View)
Functionality: Shows a single post in detail, including comments and a comment input field.
Works With:
Fetches comments from PostManager and allows adding new comments.
Allows liking/unliking the post.
Offers a follow/unfollow dialog for the post’s author using an authorProfileManager.

11. ChapterView (View)
Functionality: Displays external content (portal) using a WKWebView wrapped in a SwiftUI UIViewRepresentable called WebView.
Works With:
No direct Firestore interaction. It’s a static web portal view.

12. NotificationsView (View)
Functionality: Lists notifications like likes, comments, and follows.
Works With:
Uses NotificationManager to fetch notifications from Firestore.
Displays them in a list with descriptive text.

13. NotificationItem (Model Struct)

Fields: type, postID, senderUserID, recipientUserID, timestamp, and senderName.
Functionality: Represents a single notification.

14. NotificationManager (ObservableObject)
Functionality: Fetches notifications for the currently logged-in user.
Works With:
Fetches notification documents from notifications collection.
Uses fetchUserName(for:) to resolve senderUserID into a displayable sender name.
Provides a list of NotificationItem to NotificationsView.

How These Classes Interact

Login and Initialization:
PhiDeltConnect checks SessionManager.isLoggedIn. If false, it shows LoginView. When LoginView successfully authenticates via Firebase Auth, SessionManager.isLoggedIn = true, and the main interface (MainTabView) appears.

MainTabView and Its Child Views:

MainTabView shows multiple tabs. Each tab (e.g., HomeView, NotificationsView, CreatePostView, ChapterView, ProfileView) is a SwiftUI view that interacts with observable objects like PostManager and ProfileManager for data.
HomeView and CreatePostView share the same PostManager instance provided by MainTabView.

Profile Management:

ProfileView uses ProfileManager to fetch and display the currently viewed user’s profile. When editing is toggled, changes are saved back to Firestore.
toggleFollowUser updates Firestore’s profiles collection to reflect follow/unfollow actions and sends follow notifications.

Posts and Comments:

HomeView and ProfileView call postManager.fetchPosts() or postManager.fetchPostsByUserID() to load posts.
PostDetailView calls postManager.fetchComments(for:) to display comments. Adding a comment triggers postManager.addComment(...), updating Firestore and sending a notification.
toggleLike(for:) updates the post’s likedBy and likeCount, and creates a like notification.

For You Tab:

Uses the ProfileManager.profile fields (subtitle and lookingForWorkTitle) to determine filter criteria.
HomeView compiles a filtered list of forYouPosts based on these preferences and displays posts that match either the first word of the subtitle or the entire lookingForWorkTitle text.
Notifications:

NotificationsView displays notifications fetched by NotificationManager.
NotificationManager listens to changes in the notifications collection filtered by the recipientUserID. It resolves senderUserID to a sender name by fetching from profiles.
Firebase Workflows

User Login:

The user credentials are sent to Firebase Auth. Upon success, session.isLoggedIn updates, and the main app content loads.

Fetching Data (Posts, Profiles, Notifications):

Most fetching is done via Firestore’s listeners (addSnapshotListener). This provides real-time updates:

fetchPosts() listens to posts collection. Any new posts, likes, or changes reflect immediately in the UI.
fetchProfile() retrieves the user’s profile from profiles/<userID>.
fetchAllProfiles() retrieves all user profiles for search functionality.
fetchComments(for:) listens to posts/<postID>/comments.
fetchNotifications() listens to notifications collection filtered by the current user’s ID.
Writing Data (Posts, Comments, Followers):

Creating or updating documents (e.g., adding a post, comment, or toggling followers) is done by calling db.collection(...).document(...).setData(...) or updateData(...).
For arrays like likedBy or followers, FieldValue.arrayUnion() and FieldValue.arrayRemove() are used to efficiently update arrays in Firestore.

Notifications: When a user likes a post or comments on it, a notification is created in Firestore’s notifications collection. The NotificationManager listens to these changes and updates the UI with new notifications in real time.

![image](https://github.com/user-attachments/assets/067e8750-0689-4d36-88a7-be6acb46cb3e)
