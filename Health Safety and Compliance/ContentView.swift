//
//  ContentView.swift
//  Health Safety and Compliance
//
//  Created by Anthony Bacon on 03/10/2024.
//

import SwiftUI
import CoreLocation

//MARK: TO DO
//When not signed in, open popover on loadup
//Have a button that updates the database with a new sign in
//Use geolocation to know where user is. DONE
//store all user information securely in the database
//have a dropdown menu for all subcontractors, and use the database to display active subcontractors.
//Accident reporting - autofills data saved from user profile



struct ContentView: View {
    init() {
        setupTabBarAppearance()
    }
    
    @State private var selectedTab = 0
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    TabView(selection: $selectedTab) {
                        SignIn()
                            .tabItem {
                                Label("Sign In", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tag(0)
                            .onAppear() {
                                
                            }
                        ReportForm()
                            .tag(1)
                            .tabItem {
                                Label("Report", systemImage: "bandage.fill")
                            }
                    }.accentColor(.green)
                }
                
                
                
                Spacer()
                
            }.navigationBarTitleDisplayMode(.inline)
                .toolbar {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Image(systemName: "person.fill")
//                            .padding(10)
//                            .foregroundStyle(.green)
//                    }
                    ToolbarItem(placement: .principal) { // This places content in the center
                        Image("NEPng")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.green)
                            
                    }
                }
        }.accentColor(.orange)
    }
    private func setupTabBarAppearance() {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black // Set the background color of the tab bar

            // Customize selected and unselected tab bar item colors
            UITabBar.appearance().tintColor = UIColor.systemGreen // Selected item color
            UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray // Unselected item color
            
            // Apply to all tab bars
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
}


#Preview {
    ContentView()
}
