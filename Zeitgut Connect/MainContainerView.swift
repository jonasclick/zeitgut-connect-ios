//
//  ContentView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//

import SwiftUI

struct MainContainerView: View {
  @State private var selectedTab: Int = 0
  @State private var isShowingFAQView: Bool = false
  let session: AuthSession
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      
      TabView(selection: $selectedTab) {
        
        
        // HOME
        StartView(session: session)
          .padding(.top, 50)
          .applyAppBackground()
          .tabItem {
            Label("Start", systemImage: "house.fill")
          }
          .tag(0)
        
        // MAILBOX
        MailboxView()
          .padding(.top, 50)
          .applyAppBackground() // Hintergrund direkt hier anwenden
          .tabItem {
            Label("Briefkasten", systemImage: "envelope")
          }
          .tag(1)
        
        // MARKETPLACE
        MarketplaceView()
          .padding(.top, 50)
          .applyAppBackground()
          .tabItem {
            Label("Marktplatz", systemImage: "storefront")
          }
          .tag(2)
        
        // LOG TIME
        LogTimeView()
          .padding(.top, 50)
          .applyAppBackground()
          .tabItem {
            Label("Zeit erfassen", systemImage: "clock.badge.checkmark.fill")
          }
          .tag(3)
      }
      // Set color for the selected menu item
      .tint(.mutedSuccess)
      
      Button {
        isShowingFAQView = true
      } label: {
        Image(systemName: "questionmark")
          .font(.system(size: 20))
          .bold()
          .foregroundStyle(.softShell)
          .padding(11)
          .background(.delightfulOcean)
          .clipShape(Circle())
      }
      .padding(.trailing, 16)
      .accessibilityLabel("Hilfe und häufige Fragen")
      .zIndex(10)
    }
    .sheet(isPresented: $isShowingFAQView) {
      FAQView(isShowingFAQView: $isShowingFAQView)
        .padding()
        .applyAppBackground()
    }
  }
}

#Preview {
  MainContainerView(session: AuthSession())
}
