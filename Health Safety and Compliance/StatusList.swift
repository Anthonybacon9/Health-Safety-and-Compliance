//
//  StatusList.swift
//  Health Safety and Compliance
//
//  Created by Anthony Bacon on 15/10/2024.
//

import SwiftUI

struct StatusList: View {
    @StateObject var signInManager = SignInManager(userId: "user_id", firstName: "First", lastName: "Last") // Update with actual user ID and names

    var body: some View {
        NavigationView {
            List(signInManager.signedInUsers) { user in
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                    Text("\(user.firstName) \(user.lastName)")
                }
            } // Optional: Set a title for the navigation bar
        }
        // Removed the fetchSignedInUsers() call since it's now handled in SignInManager
    }
}

#Preview {
    StatusList()
}
