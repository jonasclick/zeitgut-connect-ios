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
          .applyAppBackground()
          .tabItem {
            Label("Start", systemImage: "house.fill")
          }
          .tag(0)
        
        // Tab 2: Suchen / Entdecken
        Text("Entdecken Screen") // Später durch eigene View ersetzen
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
      // Optional: Setzt die Farbe für das aktive Icon (z.B. Weiß, falls dein Hintergrund dunkel ist)
      .tint(.silentMint)
    }
}

#Preview {
    MainContainerView()
}
