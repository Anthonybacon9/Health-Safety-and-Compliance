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
    
    func filterRecordsByDate(selectedDate: Date, isAdmin: Bool) {
        let calendar = Calendar.current
        let selectedDayStart = calendar.startOfDay(for: selectedDate)
        let selectedDayEnd = calendar.date(byAdding: .day, value: 1, to: selectedDayStart)!

        var query: Query = db.collection("signInRecords")
            .whereField("time", isGreaterThanOrEqualTo: formatDate(date: selectedDayStart))
            .whereField("time", isLessThanOrEqualTo: formatDate(date: selectedDayEnd))

        if !isAdmin {
            // For non-admins, restrict records to their own userId
            query = query.whereField("userID", isEqualTo: userId)
        }

        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching documents: \(error)")
            } else if let snapshot = querySnapshot {
                DispatchQueue.main.async {
                    self.signInRecords = snapshot.documents.compactMap { document in
                        let data = document.data()
                        if let timeString = data["time"] as? String,
                           let time = self.parseTime(from: timeString),
                           calendar.isDate(time, inSameDayAs: selectedDate) {
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
                    // Sort by time in descending order
                    .sorted { self.parseTime(from: $0.time)! > self.parseTime(from: $1.time)! }
                }
            }
        }
    }
    
    
    
    // Fetch sign-in records based on admin view
    func fetchSignInRecords(isAdmin: Bool) {
            let today = Calendar.current.startOfDay(for: Date())
            let query: Query

            if isAdmin {
                // Admin can see all sign-in records
                query = db.collection("signInRecords")
            } else {
                // Non-admin can see only their sign-in records
                query = db.collection("signInRecords").whereField("userID", isEqualTo: userId)
            }

            query.getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting documents: \(error)")
                } else if let snapshot = querySnapshot {
                    DispatchQueue.main.async {
                        self.signInRecords = snapshot.documents.compactMap { document in
                            let data = document.data()
                            if let timeString = data["time"] as? String,
                               let time = self.parseTime(from: timeString) {
                                // Filter records for today if not admin
                                if !isAdmin && Calendar.current.startOfDay(for: time) != today {
                                    return nil
                                }
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

