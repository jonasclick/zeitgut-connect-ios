//
//  ContentView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//

import SwiftUI

struct MainContainerView: View {
  @State private var selectedTab: Int = 0
  
    var body: some View {
      TabView(selection: $selectedTab) {
        
        // Tab 1: Home
        StartView()
          .padding(.top, 50)
          .applyAppBackground()
          .tabItem {
            Label("Start", systemImage: "house.fill")
          }
          .tag(0)
        
        // Tab 2: Suchen / Entdecken
        MailboxView()
          .padding(.top, 50)
          .applyAppBackground() // Hintergrund direkt hier anwenden
          .tabItem {
            Label("Briefkasten", systemImage: "envelope")
          }
          .tag(1)
        
        // Tab 3: Mitteilungen
        Text("Nachrichten Screen")
          .applyAppBackground()
          .tabItem {
            Label("Marktplatz", systemImage: "storefront")
          }
          .tag(2)
        
        // Tab 4: Profil / Einstellungen
        Text("Profil Screen")
          .applyAppBackground()
          .tabItem {
            Label("Zeit erfassen", systemImage: "clock.badge.checkmark.fill")
          }
          .tag(3)
      }
      // Set color for the selected menu item
      .tint(.mutedSuccess)
    }
}

#Preview {
    MainContainerView()
}
