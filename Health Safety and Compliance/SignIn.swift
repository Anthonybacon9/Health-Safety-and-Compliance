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
    
    @State private var signInManager: SignInManager? // Make it an optional
    
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
            
            if selectedContract != nil {
                Button(action: {
                    signedIn.toggle()
                    let time = signInManager?.formatDate(date: Date()) ?? ""
                    let location = locationManager.userAddress ?? "Location unavailable"
                    let status = signedIn ? "Signing In" : "Signing Out"
                    let contractName = selectedContract?.name ?? "No Contract Selected"
                    
                    signInManager?.addSignInRecord(time: time, location: location, status: status, contractName: contractName)
                }, label: {
                    Circle()
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text(signedIn ? "Sign Out" : "Sign In")
                                .foregroundColor(.white)
                        }
                        .padding()
                })
                .foregroundColor(signedIn ? .red : .green)
                .disabled(!isAuthenticated)
            } else {
                Circle()
                    .frame(width: 100, height: 100)
                    .overlay {
                        Text(signedIn ? "Sign Out" : "Sign In")
                            .foregroundColor(.white)
                    }
                    .padding()
            }
            
            Divider()
            
            List(signInManager?.signInRecords ?? []) { record in
                VStack(alignment: .leading) {
                    Text("\(record.time)")
                    Text("Location: \(record.location)").font(.subheadline).foregroundColor(.gray)
                    Text("Status: \(record.status)").font(.subheadline).foregroundColor(.blue)
                    Text("Contract: \(record.contract)").font(.subheadline).foregroundColor(.purple)
                    Text("Name: \(record.firstName) \(record.lastName)").font(.subheadline).foregroundColor(.orange)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
        .onAppear {
            // Initialize the signInManager when the view appears
            signInManager = SignInManager(userId: userId, firstName: firstName, lastName: lastName)
            signInManager?.fetchSignInRecords()
        }
    }
}

#Preview {
    SignIn()
}
