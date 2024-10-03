import SwiftUI

struct Contract: Identifiable {
    let id = UUID()
    let name: String
}

struct DropdownMenu: View {
    @Binding var selectedContract: Contract?
    
    // Sample data
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
        Menu {
            ForEach(contracts) { contract in
                Button(action: {
                    selectedContract = contract // Set the selected contract
                }) {
                    Text(contract.name)
                }
            }
        } label: {
            Text(selectedContract?.name ?? "Select a Contract")
                .font(.headline)
                .padding(.vertical)
                .cornerRadius(8)
            Image(systemName: "chevron.down")
        }
    }
}

//#Preview {
//    DropdownMenu(selectedContract: ")
//}
