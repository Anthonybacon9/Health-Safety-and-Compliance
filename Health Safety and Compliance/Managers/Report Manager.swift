//
//  Report Manager.swift
//  Health Safety and Compliance
//
//  Created by Anthony Bacon on 14/10/2024.
//

import Foundation

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
    var quarterOfFinancialYear: String
    var timeOfAccident: String
    var address: String
    var phoneNumber: String
    var jobTitle: String
    var accidentContract: String
    var lineManager: String
    var employmentDetails: String
    var typeOfInjury: String
    var partOfBody: String
    var personGender: String
    var personAge: String
    var actionsTaken: String

    init(
        firstName: String,
        lastName: String,
        userId: String,
        location: String,
        date: Date,
        type: ReportType,
        description: String,
        severity: String,
        injuryReported: Bool,
        witnessNames: String,
        quarterOfFinancialYear: String,
        timeOfAccident: String,
        address: String,
        phoneNumber: String,
        jobTitle: String,
        accidentContract: String,
        lineManager: String,
        employmentDetails: String,
        typeOfInjury: String,
        partOfBody: String,
        personGender: String,
        personAge: String,
        actionsTaken: String
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.userId = userId
        self.location = location
        self.date = date
        self.type = type
        self.description = description
        self.severity = severity
        self.injuryReported = injuryReported
        self.witnessNames = witnessNames
        self.quarterOfFinancialYear = quarterOfFinancialYear
        self.timeOfAccident = timeOfAccident
        self.address = address
        self.phoneNumber = phoneNumber
        self.jobTitle = jobTitle
        self.accidentContract = accidentContract
        self.lineManager = lineManager
        self.employmentDetails = employmentDetails
        self.typeOfInjury = typeOfInjury
        self.partOfBody = partOfBody
        self.personGender = personGender
        self.personAge = personAge
        self.actionsTaken = actionsTaken
    }
}
