//
//  ReportForm.swift
//  Health Safety and Compliance
//
//  Created by Anthony Bacon on 03/10/2024.
//

import SwiftUI

struct ReportForm: View {
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var contract: String = ""
    @State var email: String = ""
    @State var phone: String = ""
    @State var report: ReportType = .accident

    var body: some View {
        VStack {
            Picker("Background Colour", selection: $report) {
                ForEach(ReportType.allCases, id: \.self) { colour in
                    Text(colour.rawValue)
                }
            }.pickerStyle(.segmented)
            
            Text(report.rawValue)
            
            TextField("Forename", text: $firstName)
                .padding()
                .autocapitalization(.none)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                )
            TextField("Surname", text: $lastName)
                .padding()
                .autocapitalization(.none)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                )
            TextField("Phone number", text: $phone)
                .padding()
                .autocapitalization(.none)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                )
        }.frame(width: 380)
        
    }
}
enum ReportType: String, CaseIterable {
    case accident = "Accident"
    case incident = "Incident"
    case nearMiss = "Near Miss"

    var type: String {
        switch self {
        case .accident:
            return "Accident"
        case .incident:
            return "Incident"
        case .nearMiss:
            return "Near Miss"
        }
    }
}

#Preview {
    ReportForm()
}
