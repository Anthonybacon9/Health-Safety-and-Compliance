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
    @AppStorage("isAdmin") var isAdmin: Bool = false
    
    @State private var isCreatingAccount: Bool = false
    @State private var isShowingPasswordChange: Bool = false
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    
    @State private var inviteCode: String = ""
    @State private var inputInviteCode: String = ""
    @State private var generatedInviteCode: String = ""
    @State private var isShowingInviteCodeError: Bool = false
    
    var body: some View {
        VStack {
            if isAuthenticated {
                // Profile Information
                VStack(spacing: 30) {
                    // Profile Image & Welcome Message
                    VStack {
                        Text("ADD AN EDIT DETAILS SECTION ON THIS PAGE")
                        Text("add reasoning 'for fast and easy completion of forms'")
                            .foregroundStyle(.red)
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.green)
                            .shadow(radius: 5)
                        
                        Text("\(username)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        Text(isAdmin ? "Administrator" : "User")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    Divider()
                    
                    // Invite Code Section for Admin
                    if isAdmin {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                if generatedInviteCode.isEmpty {
                                    Text("Generate team code")
                                        .foregroundStyle(.secondary)
                                } else {
                                    HStack {
                                        Text(generatedInviteCode)
                                            .font(.system(.body, design: .monospaced))
                                            .bold()
                                        
                                        Button(action: {
                                            UIPasteboard.general.string = generatedInviteCode
                                        }) {
                                            Image(systemName: "doc.on.doc")
                                                .foregroundColor(.blue)
                                        }
                                        .padding(.leading, 8)
                                    }
                                    .transition(.opacity)
                                }
                                
                                Spacer()
                                
                                Button(action: generateInviteCode) {
                                    Text("Generate")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                        .background(Color.green)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .animation(.easeInOut, value: generatedInviteCode)
                            
                            Text("*Generate a code for a subcontractor to distribute to their team.")
                                .font(.footnote)  // Smaller font to make it subtle
                                .foregroundColor(.gray.opacity(0.8))  // Lighter gray to blend in, but still legible
                                .italic()  // Italicized to differentiate from the main content
                                .padding(.top, 4)  // Slight padding to give it breathing room
                                .padding(.horizontal, 6)  // Padding on the sides for better alignment
                                .multilineTextAlignment(.leading)  // Align text for readability
                        }
                    }
                    
                    // Account Management (Change Password & Sign Out)
                    VStack(spacing: 15) {
                        Button(action: { isShowingPasswordChange = true }) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundColor(.orange)
                                Text("Change Password")
                                    .foregroundColor(.orange)
                            }
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
                            HStack {
                                Image(systemName: "arrowshape.turn.up.left.fill")
                                    .foregroundColor(.red)
                                Text("Sign Out")
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            } else {
                if isCreatingAccount {
                    // Sign-Up Form
                    VStack(spacing: 20) {
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        TextField("Invite Code", text: $inputInviteCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if isShowingInviteCodeError {
                            Text("Invalid or expired invite code.")
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                        
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
                        
                        Button(action: validateInviteCodeAndCreateAccount) {
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
    
    private func generateInviteCode() {
        let code = UUID().uuidString.prefix(8) // Generates a random 8-character code
        let db = Firestore.firestore()
        
        db.collection("inviteCodes").document(String(code)).setData([
            "code": code,
            "isUsed": false // If you want to make it reusable, change logic accordingly
        ]) { error in
            if let error = error {
                print("Error creating invite code: \(error.localizedDescription)")
            } else {
                generatedInviteCode = String(code)
                print("Invite code generated successfully!")
            }
        }
    }
    
    
    private func validateInviteCodeAndCreateAccount() {
        let db = Firestore.firestore()
        db.collection("inviteCodes").document(inputInviteCode).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let isUsed = data?["isUsed"] as? Bool ?? true
                
                if !isUsed {
                    // If valid, create the account
                    createAccount()
                    
                    // Mark the invite code as used if needed (optional)
                    //db.collection("inviteCodes").document(inputInviteCode).updateData(["isUsed": true])
                } else {
                    isShowingInviteCodeError = true
                }
            } else {
                isShowingInviteCodeError = true
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
                isAdmin = data?["isAdmin"] as? Bool ?? false
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
            "uid": userId,
            "isAdmin": false,
            "invCode" : inputInviteCode,
            "isSignedIn" : false
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
            isAdmin = false
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
}

#Preview {
    UserProfile()
}
