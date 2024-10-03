import SwiftUI
import FirebaseFirestore

struct SignInRecord: Identifiable {
    let id = UUID()  // Swift will generate the id automatically
    let time: String
    let location: String
    let status: String
    let contract: String
}

struct SignIn: View {
    @StateObject private var timeManager = TimeManager()
    @StateObject private var locationManager = LocationManager()

    @State var signedIn: Bool = false
    @State private var signInRecords: [SignInRecord] = []  // Store sign-in records
    @State private var selectedContract: Contract? // Track the selected contract

    // Sample contract data
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
    
    // Firestore reference
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            // Dropdown menu to select a contract
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
                    .padding(.vertical)
                Image(systemName: "chevron.down")
            }

            // Toggle sign-in/out state
            Button(action: {
                signedIn.toggle()
                addSignInRecord() // Add a new record when button is pressed
            }, label: {
                Circle()
                    .frame(width: 100, height: 100)
                    .overlay {
                        Text(signedIn ? "Sign Out" : "Sign In")
                            .foregroundColor(.white)
                    }
            })
            .foregroundColor(signedIn ? .red : .green)

            Divider()

            // Display sign-in records
            List(signInRecords) { record in
                VStack(alignment: .leading) {
                    Text("Time: \(record.time)")
                    Text("Location: \(record.location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Status: \(record.status)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("Contract: \(record.contract)")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
        .onAppear {
            fetchSignInRecords() // Fetch records from Firestore on appear
        }
    }

    // Add a new sign-in record with the current time, location, and selected contract
    private func addSignInRecord() {
        let time = timeManager.currentTime
        let location = locationManager.userAddress ?? "Location unavailable"
        let status = signedIn ? "Signing In" : "Signing Out"
        let contractName = selectedContract?.name ?? "No Contract Selected"
        
        let newRecord = SignInRecord(time: time, location: location, status: status, contract: contractName)

        // Append record locally
        signInRecords.append(newRecord)

        // Save the record to Firestore
        saveToFirestore(record: newRecord)
    }

    // Function to save the record to Firestore
    private func saveToFirestore(record: SignInRecord) {
        let recordData: [String: Any] = [
            "time": record.time,
            "location": record.location,
            "status": record.status,
            "contract": record.contract
        ]
        
        db.collection("signInRecords").addDocument(data: recordData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Record successfully written!")
            }
        }
    }

    // Fetch sign-in records from Firestore
    private func fetchSignInRecords() {
        db.collection("signInRecords").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else if let snapshot = querySnapshot {
                DispatchQueue.main.async {
                    signInRecords = snapshot.documents.compactMap { document in
                        let data = document.data()
                        return SignInRecord(
                            time: data["time"] as? String ?? "N/A",
                            location: data["location"] as? String ?? "N/A",
                            status: data["status"] as? String ?? "N/A",
                            contract: data["contract"] as? String ?? "N/A"
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    SignIn()
}
