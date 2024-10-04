import SwiftUI
import FirebaseFirestore

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

    @State var signedIn: Bool = false
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @State private var signInRecords: [SignInRecord] = []  // Store sign-in records
    @State private var selectedContract: Contract? // Track the selected contract
    
    // User's first name and last name from UserProfile
    @AppStorage("firstName") var firstName: String = ""
    @AppStorage("lastName") var lastName: String = ""
    @AppStorage("uid") var userId: String = ""

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
                    .padding()
            })
            .foregroundColor(signedIn ? .red : .green)
            .disabled(!isAuthenticated) // Disable if not authenticated

            Divider()

            // Display sign-in records
            List(signInRecords) { record in
                VStack(alignment: .leading) {
                    Text("\(record.time)")
                    Text("Location: \(record.location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Status: \(record.status)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("Contract: \(record.contract)")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                    Text("Name: \(record.firstName) \(record.lastName)")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
        .onAppear {
            fetchSignInRecords()
            // Fetch records from Firestore on appear
        }
    }

    // Add a new sign-in record with the current time, location, selected contract, and user's name
    private func addSignInRecord() {
        let date = Date()
        let time = formatDate(date: date)  // Store the current time in the correct format
        let location = locationManager.userAddress ?? "Location unavailable"
        let status = signedIn ? "Signing In" : "Signing Out"
        let contractName = selectedContract?.name ?? "No Contract Selected"

        // Retrieve first name and last name
        let firstName = UserDefaults.standard.string(forKey: "firstName") ?? "No First Name"
        let lastName = UserDefaults.standard.string(forKey: "lastName") ?? "No Last Name"
        
        let newRecord = SignInRecord(
            time: time,
            location: location,
            status: status,
            contract: contractName,
            firstName: firstName,   // Store first name
            lastName: lastName      // Store last name
        )

        // Append record locally
        signInRecords.insert(newRecord, at: 0)

        // Save the record to Firestore including the user ID
        saveToFirestore(record: newRecord)
    }
    
    // Function to save the record to Firestore
    private func saveToFirestore(record: SignInRecord) {
        let recordData: [String: Any] = [
            "time": record.time,
            "location": record.location,
            "status": record.status,
            "contract": record.contract,
            "firstName": record.firstName,  // Include first name
            "lastName": record.lastName,    // Include last name
            "userID": userId                // Store user ID in Firestore (but don't display it)
        ]
        
        db.collection("signInRecords").addDocument(data: recordData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Record successfully written!")
            }
        }
    }

    // Fetch sign-in records from Firestore for today's date and the current user
    private func fetchSignInRecords() {
        // Ensure the userId is available
        guard !userId.isEmpty else {
            print("Error: User ID is not available")
            return
        }

        // Get today's date
        let today = Calendar.current.startOfDay(for: Date())

        db.collection("signInRecords")
            .whereField("userID", isEqualTo: userId)  // Filter records by user ID
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else if let snapshot = querySnapshot {
                    DispatchQueue.main.async {
                        // Fetch and filter today's records, then sort by time in descending order
                        signInRecords = snapshot.documents.compactMap { document in
                            let data = document.data()
                            
                            // Parse the time string into a Date object
                            if let timeString = data["time"] as? String,
                               let time = parseTime(from: timeString) {
                                
                                // Compare the date part of the time with today's date
                                let recordDate = Calendar.current.startOfDay(for: time)
                                
                                // Include the record only if it matches today's date
                                if recordDate == today {
                                    return SignInRecord(
                                        time: timeString,
                                        location: data["location"] as? String ?? "N/A",
                                        status: data["status"] as? String ?? "N/A",
                                        contract: data["contract"] as? String ?? "N/A",
                                        firstName: data["firstName"] as? String ?? "N/A", // Retrieve first name
                                        lastName: data["lastName"] as? String ?? "N/A"    // Retrieve last name
                                    )
                                }
                            }
                            return nil
                        }
                        // Sort the records by time in descending order (most recent at the top)
                        .sorted { record1, record2 in
                            if let time1 = parseTime(from: record1.time),
                               let time2 = parseTime(from: record2.time) {
                                return time1 > time2  // Sort in descending order
                            }
                            return false
                        }
                    }
                }
            }
    }
    
    private func parseTime(from timeString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // Adjust this format based on how your time is stored
        return dateFormatter.date(from: timeString)
    }
    
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // Format to match Firestore storage format
        return dateFormatter.string(from: date)
    }
}

#Preview {
    SignIn()
}
