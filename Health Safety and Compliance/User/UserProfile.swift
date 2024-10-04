import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserProfile: View {
    @AppStorage("username") var username: String = ""
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @State private var errorMessage: String? = nil
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @AppStorage("firstName") var firstName: String = ""
    @AppStorage("lastName") var lastName: String = ""
    @AppStorage("uid") var userId: String = ""
    
    @State private var isCreatingAccount: Bool = false
    @State private var isChangingPassword: Bool = false
    @State private var newPassword: String = ""
    @State private var currentPassword: String = ""
    @State private var reenteredPassword: String = ""
    
    var body: some View {
        VStack {
            if isAuthenticated {
                // Profile Information
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.green)
                    
                    Text("Welcome, \(username)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button(action: signOut) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    
                    // Change Password Section
                    if isChangingPassword {
                        VStack(spacing: 15) {
                            SecureField("Current Password", text: $currentPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            SecureField("New Password", text: $newPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            SecureField("Re-enter New Password", text: $reenteredPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: changePassword) {
                                Text("Update Password")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                            
                            if let error = errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }
                        }
                    } else {
                        Button(action: { isChangingPassword = true }) {
                            Text("Change Password")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
            } else {
                // Existing Sign-In and Sign-Up Forms (no changes here)
            }
        }
        .onAppear {
            // Automatically check if the user is authenticated on app launch
            if let user = Auth.auth().currentUser {
                username = user.displayName ?? user.email ?? "Unknown User"
                userId = user.uid // Store the uid
                isAuthenticated = true
            }
        }
    }
    
    // Function to handle password change
    private func changePassword() {
        guard newPassword == reenteredPassword else {
            errorMessage = "New passwords do not match."
            return
        }
        
        // Reauthenticate the user with their current password before updating
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "Reauthentication failed: \(error.localizedDescription)"
                return
            }
            
            // Proceed to update the password
            Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                if let error = error {
                    errorMessage = "Failed to update password: \(error.localizedDescription)"
                } else {
                    errorMessage = "Password updated successfully."
                    isChangingPassword = false
                }
            }
        }
    }

    // Firebase Sign-In Function
    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            if let user = authResult?.user {
                username = user.displayName ?? user.email ?? "Unknown User"
                userId = user.uid // Save the uid
                isAuthenticated = true

                fetchUserData(userId: user.uid)
            }
        }
    }
    
    private func fetchUserData(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                firstName = data?["firstName"] as? String ?? "No First Name"
                lastName = data?["lastName"] as? String ?? "No Last Name"
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // Firebase Create Account Function
    private func createAccount() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            if let user = authResult?.user {
                // Save user information to Firestore
                saveUserData(userId: user.uid)
                
                // Optionally set the display name
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = firstName + " " + lastName
                changeRequest.commitChanges { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        username = user.displayName ?? user.email ?? "Unknown User"
                        isAuthenticated = true
                        userId = user.uid // Store the uid
                    }
                }
            }
        }
    }

    // Function to save user data to Firestore
    private func saveUserData(userId: String) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "uid": userId
        ]

        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                errorMessage = "Error saving user data: \(error.localizedDescription)"
            } else {
                print("User data successfully saved!")
            }
        }
    }

    // Firebase Sign-Out Function
    private func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            username = ""
            email = ""
            password = ""
            confirmPassword = ""
            firstName = ""
            lastName = ""
            userId = ""
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
}

#Preview {
    UserProfile()
}
