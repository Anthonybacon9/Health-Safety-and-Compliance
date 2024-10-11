//
//  FirestoreManager.swift
//  Health Safety and Compliance
//
//  Created by Anthony Bacon on 11/10/2024.
//
import Foundation
import FirebaseFirestore

struct Report {
    var firstName: String
    var lastName: String
    var userId: String
    var location: String
    var date: Date
    var type: ReportType
    var description: String
    var severity: String
    var injuryReported: Bool
    var witnessNames: String
}

class FirestoreManager {
    private var db = Firestore.firestore()
    
    func addReport(report: Report) {
        let reportData: [String: Any] = [
            "firstName": report.firstName,
            "lastName": report.lastName,
            "uid": report.userId,
            "location": report.location,
            "date": report.date,
            "description": report.description,
            "severity": report.severity,
            "injuryReported": report.injuryReported,
            "witnessNames": report.witnessNames
        ]
        
        // Choose the collection based on the report type
        let collectionName: String
        switch report.type {
        case .accident:
            collectionName = "Accidents"
        case .incident:
            collectionName = "Incidents"
        case .nearMiss:
            collectionName = "NearMisses"
        }
        
        // Add the report to the appropriate collection
        db.collection(collectionName).addDocument(data: reportData) { error in
            if let error = error {
                print("Error adding report: \(error)")
            } else {
                print("Report successfully added to \(collectionName) collection!")
            }
        }
    }
}
