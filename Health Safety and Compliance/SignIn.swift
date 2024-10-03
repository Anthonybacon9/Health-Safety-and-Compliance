//
//  SignIn.swift
//  Health Safety and Compliance
//
//  Created by Anthony Bacon on 03/10/2024.
//

import SwiftUI

struct SignInRecord: Identifiable {
    let id = UUID()
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

    var body: some View {
        VStack {
            DropdownMenu(selectedContract: $selectedContract) // Pass binding to selected contract
            // Toggle sign-in/out state
            Button(action: {
                signedIn.toggle()
                addSignInRecord()  // Add a new record when button is pressed
            }, label: {
                Circle()
                    .frame(width: 100, height: 100)
                    .overlay {
                        Text(signedIn ? "In" : "Out")
                            .foregroundStyle(.white)
                    }
            })
            .buttonStyle(PlainButtonStyle())
            .foregroundStyle(signedIn ? .green : .red)

            Divider()

            // Display sign-in records
            List(signInRecords) { record in
                VStack(alignment: .leading) {
                    Text("Time: \(record.time)")
                    Text("Location: \(record.location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Status: \(record.status)") // Display the status
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("Contract: \(record.contract)") // Display the selected contract
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
    }

    // Add a new sign-in record with the current time, location, and selected contract
    private func addSignInRecord() {
        let time = timeManager.currentTime
        let location = locationManager.userAddress ?? "Location unavailable"
        let status = signedIn ? "Signing In" : "Signing Out" // Determine the status
        let contractName = selectedContract?.name ?? "No Contract Selected" // Get contract name

        let newRecord = SignInRecord(time: time, location: location, status: status, contract: contractName)
        signInRecords.append(newRecord)
    }
}

#Preview {
    SignIn()
}
