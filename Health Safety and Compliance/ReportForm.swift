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
    @State private var quarterOfFinancialYear: String = ""
    @State private var timeOfAccident: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var jobTitle: String = ""
    @State private var accidentContract: String = ""
    @State private var lineManager: String = ""
    @State private var employmentDetails: String = ""
    @State private var typeOfInjury: String = ""
    @State private var partOfBody: String = ""
    @State private var personGender: String = ""
    @State private var personAge: String = ""
    @State private var actionsTaken: String = ""

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
            witnessNames: witnessNames,
            quarterOfFinancialYear: quarterOfFinancialYear,
            timeOfAccident: timeOfAccident,
            address: address,
            phoneNumber: phoneNumber,
            jobTitle: jobTitle,
            accidentContract: accidentContract,
            lineManager: lineManager,
            employmentDetails: employmentDetails,
            typeOfInjury: typeOfInjury,
            partOfBody: partOfBody,
            personGender: personGender,
            personAge: personAge,
            actionsTaken: actionsTaken
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
        
        // Additional Questions
        TextField("Quarter of Financial Year", text: $quarterOfFinancialYear)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Time of the Accident", text: $timeOfAccident)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Your Address", text: $address)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Phone Number", text: $phoneNumber)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Job Title", text: $jobTitle)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Accident Contract", text: $accidentContract)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Who is Your Line Manager?", text: $lineManager)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Employment Details (Employee, Subcontractor, or Member of Public)", text: $employmentDetails)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Type of Injury", text: $typeOfInjury)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Part of Body", text: $partOfBody)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Person's Gender", text: $personGender)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Person's Age", text: $personAge)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Describe Actions Taken to Prevent From Happening Again", text: $actionsTaken)
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
        
        // Additional Questions
        TextField("Quarter of Financial Year", text: $quarterOfFinancialYear)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Time of the Incident", text: $timeOfAccident)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Your Address", text: $address)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Phone Number", text: $phoneNumber)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Job Title", text: $jobTitle)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Incident Contract", text: $accidentContract) // You may want to specify differently for incidents
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Who is Your Line Manager?", text: $lineManager)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Employment Details (Employee, Subcontractor, or Member of Public)", text: $employmentDetails)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Type of Injury", text: $typeOfInjury)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Part of Body", text: $partOfBody)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Person's Gender", text: $personGender)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Person's Age", text: $personAge)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke())
        
        TextField("Describe Actions Taken to Prevent From Happening Again", text: $actionsTaken)
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
