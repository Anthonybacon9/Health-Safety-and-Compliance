//
//  Register Manager.swift
//  Health Safety and Compliance
//
//  Created by Anthony Bacon on 07/10/2024.
//

import Foundation
import FirebaseFirestore

class SignInManager: ObservableObject {
    @Published var signInRecords: [SignInRecord] = []
    
    private let db = Firestore.firestore()
    private let userId: String
    private let firstName: String
    private let lastName: String
    
    init(userId: String, firstName: String, lastName: String) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
    }
    
    // Add a new sign-in record
    func addSignInRecord(time: String, location: String, status: String, contractName: String) {
        let newRecord = SignInRecord(
            time: time,
            location: location,
            status: status,
            contract: contractName,
            firstName: firstName,
            lastName: lastName
        )
        
        signInRecords.insert(newRecord, at: 0)
        saveToFirestore(record: newRecord)
    }
    
    // Save the record to Firestore
    private func saveToFirestore(record: SignInRecord) {
        let recordData: [String: Any] = [
            "time": record.time,
            "location": record.location,
            "status": record.status,
            "contract": record.contract,
            "firstName": record.firstName,
            "lastName": record.lastName,
            "userID": userId
        ]
        
        db.collection("signInRecords").addDocument(data: recordData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Record successfully written!")
            }
        }
    }
    
    // Fetch sign-in records for today and the current user
    func fetchSignInRecords() {
        let today = Calendar.current.startOfDay(for: Date())
        
        db.collection("signInRecords")
            .whereField("userID", isEqualTo: userId)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting documents: \(error)")
                } else if let snapshot = querySnapshot {
                    DispatchQueue.main.async {
                        self.signInRecords = snapshot.documents.compactMap { document in
                            let data = document.data()
                            if let timeString = data["time"] as? String,
                               let time = self.parseTime(from: timeString),
                               Calendar.current.startOfDay(for: time) == today {
                                return SignInRecord(
                                    time: timeString,
                                    location: data["location"] as? String ?? "N/A",
                                    status: data["status"] as? String ?? "N/A",
                                    contract: data["contract"] as? String ?? "N/A",
                                    firstName: data["firstName"] as? String ?? "N/A",
                                    lastName: data["lastName"] as? String ?? "N/A"
                                )
                            }
                            return nil
                        }
                        .sorted { self.parseTime(from: $0.time)! > self.parseTime(from: $1.time)! }
                    }
                }
            }
    }
    
    private func parseTime(from timeString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: timeString)
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}

