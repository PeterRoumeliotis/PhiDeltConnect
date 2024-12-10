import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ProfileManager: ObservableObject {
    @Published var profile = Profile(name: "", subtitle: "", about: "", experience: "", yearsInFraternity: 0)
    private let db = Firestore.firestore()
    private let userID: String? = Auth.auth().currentUser?.uid

    func fetchProfile() {
        guard let userID = userID else { return }

        db.collection("profiles").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching profile: \(error.localizedDescription)")
                return
            }
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.profile.name = data["name"] as? String ?? ""
                    self.profile.subtitle = data["subtitle"] as? String ?? ""
                    self.profile.about = data["about"] as? String ?? ""
                    self.profile.experience = data["experience"] as? String ?? ""
                    self.profile.yearsInFraternity = data["yearsInFraternity"] as? Int ?? 0
                }
            }
        }
    }

    func saveProfile() {
        guard let userID = userID else { return }

        let profileData: [String: Any] = [
            "name": profile.name,
            "subtitle": profile.subtitle,
            "about": profile.about,
            "experience": profile.experience,
            "yearsInFraternity": profile.yearsInFraternity
        ]

        db.collection("profiles").document(userID).setData(profileData) { error in
            if let error = error {
                print("Error saving profile: \(error.localizedDescription)")
            } else {
                print("Profile saved successfully!")
            }
        }
    }
}
