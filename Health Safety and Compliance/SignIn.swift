import SwiftUI
import FirebaseFirestore

struct Contract: Identifiable {
    let id = UUID()
    let name: String
}

struct SignInRecord: Identifiable {
    let id = UUID()  // Swift will generate the id automatically
    let time: String
    let location: String
    let status: String
    let contract: String
    let firstName: String // New property for first name
    let lastName: String  // New property for last name
}

struct SignIn: View {
    @StateObject private var timeManager = TimeManager()
    @StateObject private var locationManager = LocationManager()
    
    @AppStorage("signedIn") var signedIn: Bool = false
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @AppStorage("firstName") var firstName: String = ""
    @AppStorage("lastName") var lastName: String = ""
    @AppStorage("uid") var userId: String = ""
    @AppStorage("isAdmin") var isAdmin: Bool = false
    
    @State private var adminView: Bool = false
    @State private var signInManager: SignInManager?
    @State private var selectedContract: Contract?
    
    let contracts = [
        Contract(name: "ECO4"),
        Contract(name: "Plus Dane SHDF"),
        Contract(name: "Torus"),
        Contract(name: "Livv SHDF"),
        Contract(name: "Sandwell SHDF"),
        Contract(name: "WMCA HUG"),
        Contract(name: "Northumberland HUG"),
        Contract(name: "Manchester HUG"),
        Contract(name: "Cheshire East HUG"),
        Contract(name: "Weaver Vale")
    ]
    
    var body: some View {
        VStack {
            HStack {
                Menu {
                    ForEach(contracts) { contract in
                        Button(action: {
                            selectedContract = contract
                        }) {
                            Text(contract.name)
                        }
                    }
                } label: {
                    Text(selectedContract?.name ?? "Select Contract")
                    Image(systemName: "chevron.down")
                }
                if isAdmin {
                    Spacer()
                    Button {
                        adminView.toggle()
                        signInManager?.fetchSignInRecords(isAdmin: adminView) // Fetch records based on admin view status
                    } label: {
                        Text("See all")
                            .foregroundStyle(.blue)
                        Image(systemName: adminView ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(.blue)
                    }
                }
            }.padding(.horizontal)
            
            if selectedContract != nil {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        signedIn.toggle()
                    }
                    let time = signInManager?.formatDate(date: Date()) ?? ""
                    let location = locationManager.userAddress ?? "Location unavailable"
                    let status = signedIn ? "Signing In" : "Signing Out"
                    let contractName = selectedContract?.name ?? "No Contract Selected"
                    
                    signInManager?.addSignInRecord(time: time, location: location, status: status, contractName: contractName)
                }) {
                    HStack {
                        Image(systemName: signedIn ? "person.fill.checkmark" : "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .scaleEffect(signedIn ? 1.2 : 1.0)  // Scale effect for the icon
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: signedIn)
                        
                        Text(signedIn ? "Sign Out" : "Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(gradient: Gradient(colors: signedIn ? [.red, .orange] : [.green, .blue]),
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                    )
                    .shadow(color: signedIn ? Color.red.opacity(0.5) : Color.green.opacity(0.5), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .scaleEffect(signedIn ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: signedIn)
                }
                .disabled(!isAuthenticated)
            } else {
                Text("Select a contract to sign in")
                    .italic()
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            Divider()
            
            // Display the sign-in records based on admin view status
            List(signInManager?.signInRecords ?? []) { record in
                VStack(alignment: .leading) {
                    Text("\(record.firstName) \(record.lastName)")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Text("Contract: \(record.contract)")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                    Text("Status: \(record.status)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("Location: \(record.location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Time: \(record.time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
        .onAppear {
            // Initialize the signInManager when the view appears
            signInManager = SignInManager(userId: userId, firstName: firstName, lastName: lastName)
            signInManager?.fetchSignInRecords(isAdmin: adminView) // Fetch records on appear
        }
    }
}

#Preview {
    SignIn()
}
