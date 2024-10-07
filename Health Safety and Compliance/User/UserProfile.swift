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
    @State private var isShowingPasswordChange: Bool = false
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""

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

                    // Change Password Button
                    Button(action: { isShowingPasswordChange = true }) {
                        Text("Change Password")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                    .popover(isPresented: $isShowingPasswordChange) {
                        VStack(spacing: 20) {
                            Text("Change Password")
                                .font(.headline)
                            
                            SecureField("New Password", text: $newPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            SecureField("Confirm New Password", text: $confirmNewPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if let error = errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }

                            Button(action: updatePassword) {
                                Text("Update Password")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    }

                    Button(action: signOut) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                .padding()
            } else {
                if isCreatingAccount {
                    // Sign-Up Form
                    VStack(spacing: 20) {
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }

                        Button(action: createAccount) {
                            Text("Create Account")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }

                        Button(action: { isCreatingAccount = false }) {
                            Text("Already have an account? Sign In")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                } else {
                    // Sign-In Form
                    VStack(spacing: 20) {
                        Text("Sign In")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }

                        Button(action: signIn) {
                            Text("Sign In")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }

                        Button(action: { isCreatingAccount = true }) {
                            Text("Don't have an account? Create one")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                }
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

    // Firebase Password Update Function
    private func updatePassword() {
        guard newPassword == confirmNewPassword else {
            errorMessage = "New passwords do not match."
            return
        }

        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            if let error = error {
                errorMessage = "Failed to update password: \(error.localizedDescription)"
            } else {
                isShowingPasswordChange = false
                print("Password successfully updated!")
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
