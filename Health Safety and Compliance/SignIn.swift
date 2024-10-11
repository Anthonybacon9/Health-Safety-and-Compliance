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
    let firstName: String
    let lastName: String
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
    @State private var isCalendarPresented = false
    @State private var selectedDate = Date()
    
    
    @State private var showSignInSheet = false
    @State private var question1Answer = false
    @State private var question2Answer = false
    @State private var question3Answer = false
    @State private var question4Answer = false
    @State private var question5Answer = false
    @State private var question6Answer = false
    @State private var question7Answer = false
    @State private var question8Answer = false
    
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
                    Text(selectedContract?.name ?? "Contract")
                    Image(systemName: "chevron.down")
                }.disabled(signedIn)
                Spacer()
                Button {
                    isCalendarPresented.toggle() // Toggle calendar
                } label: {
                    Image(systemName: "calendar")
                        .foregroundStyle(.green)
                }
                .sheet(isPresented: $isCalendarPresented) {
                    VStack {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle()) // Use a graphical calendar
                        .padding()

                        Button("Done") {
                            isCalendarPresented = false
                            signInManager?.filterRecordsByDate(selectedDate: selectedDate, isAdmin: isAdmin)
                        }
                        .padding()
                    }
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
                    if !signedIn {
                        // Show the sheet for signing in
                        showSignInSheet.toggle()
                    } else {
                        // Directly sign out without the sheet
                        withAnimation(.easeInOut(duration: 0.3)) {
                            signedIn.toggle()
                        }
                        let time = signInManager?.formatDate(date: Date()) ?? ""
                        let location = locationManager.userAddress ?? "Location unavailable"
                        let status = signedIn ? "Signing In" : "Signing Out"
                        let contractName = selectedContract?.name ?? "No Contract Selected"
                        
                        signInManager?.addSignInRecord(time: time, location: location, status: status, contractName: contractName)
                    }
                }) {
                    HStack {
                        Image(systemName: signedIn ? "person.fill.checkmark" : "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .scaleEffect(signedIn ? 1.2 : 1.0)  // Scale effect for the icon
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: signedIn)
                        
                        Text(signedIn ? "Sign Out" : "Sign In")
                            .font(Font.custom("Poppins-Medium", size: 18))
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
                .sheet(isPresented: $showSignInSheet) {
                    VStack {
                        Text("Point of works risk assessment")
                            .font(.headline)
                            .padding()

                        Toggle("I have got the correct information to do the job", isOn: $question1Answer)
                            .padding(.bottom, 10)
                        Toggle("I have read and understood the relevant safe systems of work", isOn: $question2Answer)
                            .padding(.bottom, 10)
                        Toggle("I understand what measures I must do to control the hazards / risks", isOn: $question3Answer)
                            .padding(.bottom, 10)
                        Toggle("I have the correct PPE for the task", isOn: $question4Answer)
                            .padding(.bottom, 10)
                        Toggle("I have the correct equipment", isOn: $question5Answer)
                            .padding(.bottom, 10)
                        Toggle("I have been trained to do the task and operate the equipment provided", isOn: $question6Answer)
                            .padding(.bottom, 10)
                        Toggle("I know and understand what actions to take in the event of an emergency", isOn: $question7Answer)
                            .padding(.bottom, 10)
                        Toggle("Do you have evidence of your identification/qualifications on hand?", isOn: $question8Answer)
                            .padding(.bottom, 10)

                        Button(action: {
                            showSignInSheet = false
                            question1Answer = false
                            question2Answer = false
                            question3Answer = false
                            question4Answer = false
                            question5Answer = false
                            question6Answer = false
                            question7Answer = false
                            question8Answer = false
                            // Process the sign-in once the user clicks Done
                            withAnimation(.easeInOut(duration: 0.3)) {
                                signedIn.toggle()
                            }
                            let time = signInManager?.formatDate(date: Date()) ?? ""
                            let location = locationManager.userAddress ?? "Location unavailable"
                            let status = "Signing In"
                            let contractName = selectedContract?.name ?? "No Contract Selected"
                            
                            signInManager?.addSignInRecord(time: time, location: location, status: status, contractName: contractName)

                            // Dismiss the sheet
                            showSignInSheet = false
                        }) {
                            Text("Done")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(20)
                }
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
