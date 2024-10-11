import SwiftUI

struct ReportForm: View {
    @AppStorage("firstName") var firstName: String = ""
    @AppStorage("lastName") var lastName: String = ""
    @AppStorage("uid") var userId: String = ""
    @AppStorage("isAdmin") var isAdmin: Bool = false

    @State private var report: ReportType = .accident
    @State private var accidentDescription: String = ""
    @State private var incidentDetails: String = ""
    @State private var nearMissDetails: String = ""
    @State private var location: String = ""
    @State private var date: Date = Date()
    @State private var severity: String = ""
    @State private var witnessNames: String = ""
    @State private var injuryReported: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Picker("Report Type", selection: $report) {
                    ForEach(ReportType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                Text(report.rawValue)
                    .font(.headline)
                    .padding(.top)
                
                TextField("Forename", text: $firstName)
                    .padding()
                    .autocapitalization(.none)
                    .background(RoundedRectangle(cornerRadius: 10).stroke())
                    .disabled(true)
                
                TextField("Surname", text: $lastName)
                    .padding()
                    .autocapitalization(.none)
                    .background(RoundedRectangle(cornerRadius: 10).stroke())
                    .disabled(true)
                
                TextField("Location", text: $location)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke())
                
                DatePicker("Date of Report", selection: $date, displayedComponents: .date)
                    .padding()
                
                switch report {
                case .accident:
                    AccidentQuestions()
                case .incident:
                    IncidentQuestions()
                case .nearMiss:
                    NearMissQuestions()
                }
                
                // Submit Button
                Button(action: submitReport) {
                    Text("Submit Report")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                Spacer()
            }
            .padding(10)
        }
    }

    private func submitReport() {
        let report = Report(
            firstName: firstName,
            lastName: lastName,
            userId: userId,
            location: location,
            date: date,
            type: report,
            description: getDescriptionForReportType(),
            severity: severity,
            injuryReported: injuryReported,
            witnessNames: witnessNames
        )
        
        let firestoreManager = FirestoreManager()
        firestoreManager.addReport(report: report)
    }

    private func getDescriptionForReportType() -> String {
        switch report {
        case .accident:
            return accidentDescription
        case .incident:
            return incidentDetails
        case .nearMiss:
            return nearMissDetails
        }
    }
    
    @ViewBuilder
    private func AccidentQuestions() -> some View {
        TextField("Describe the Accident", text: $accidentDescription)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Reported Severity (e.g., Minor, Moderate, Severe)", text: $severity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        Toggle("Was there an injury reported?", isOn: $injuryReported)
            .padding()
        
        TextField("Witness Names (if any)", text: $witnessNames)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
    }
    
    @ViewBuilder
    private func IncidentQuestions() -> some View {
        TextField("Describe the Incident", text: $incidentDetails)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Impact of Incident", text: $severity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        Toggle("Was there any damage reported?", isOn: $injuryReported)
            .padding()
        
        TextField("Witness Names (if any)", text: $witnessNames)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
    }
    
    @ViewBuilder
    private func NearMissQuestions() -> some View {
        TextField("Describe the Near Miss", text: $nearMissDetails)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Potential Severity if it were an accident", text: $severity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        Toggle("Was there a safety breach involved?", isOn: $injuryReported)
            .padding()
        
        TextField("Witness Names (if any)", text: $witnessNames)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
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
