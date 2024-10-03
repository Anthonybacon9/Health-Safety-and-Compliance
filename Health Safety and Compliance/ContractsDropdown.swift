import SwiftUI

struct Contract: Identifiable {
    let id = UUID()
    let name: String
}

//struct DropdownMenu: View {
//    @Binding var selectedContract: Contract?
//    
//    // Sample data
//    
//
//    var body: some View {
//        Menu {
//            ForEach(contracts) { contract in
//                Button(action: {
//                    selectedContract = contract // Set the selected contract
//                }) {
//                    Text(contract.name)
//                }
//            }
//        } label: {
//            Text(selectedContract?.name ?? "Select a Contract")
//                .font(.headline)
//                .padding(.vertical)
//                .cornerRadius(8)
//            Image(systemName: "chevron.down")
//        }
//    }
//}

//#Preview {
//    DropdownMenu(selectedContract: ")
//}
