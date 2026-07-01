//
//  ContentView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//

import SwiftUI

struct MainContainerView: View {
  @Binding var session: AuthSession
  @Environment(\.scenePhase) private var scenePhase
  @State private var selectedTab: Int = 0
  @State private var isShowingFAQView: Bool = false
  @State private var refreshGeneration = 0
  @State private var didHandleInitialActiveScene = false

  private let authService = AuthService()
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      
      TabView(selection: $selectedTab) {
        

        // HOME
        StartView(session: $session, refreshGeneration: refreshGeneration)
          .padding(.top, 50)
          .applyAppBackground()
          .tabItem {
            Label("Start", systemImage: "house.fill")
          }
          .tag(0)

        // MAILBOX
        MailboxView(session: $session, refreshGeneration: refreshGeneration)
          .padding(.top, 50)
          .applyAppBackground() // Hintergrund direkt hier anwenden
          .tabItem {
            Label("Briefkasten", systemImage: "envelope")
          }
          .tag(1)
        
        // MARKETPLACE
        // MarketplaceView()
          // .padding(.top, 50)
          // .applyAppBackground()
          // .tabItem {
           // Label("Marktplatz", systemImage: "storefront")
          // }
          //.tag(2)
        
        // LOG TIME
        LogTimeView(session: session)
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
    .task(id: scenePhase) {
      guard scenePhase == .active else {
        return
      }

      await refreshSessionSnapshot()
      if didHandleInitialActiveScene {
        refreshGeneration += 1
      } else {
        didHandleInitialActiveScene = true
      }
    }
    .onChange(of: selectedTab) { _, _ in
      Task { @MainActor in
        await refreshSessionSnapshot()
        refreshGeneration += 1
      }
    }
    .sheet(isPresented: $isShowingFAQView) {
      FAQView(isShowingFAQView: $isShowingFAQView)
        .padding()
        .applyAppBackground()
    }
  }

  @MainActor
  private func refreshSessionSnapshot() async {
    guard session.accessToken.isEmpty == false else {
      return
    }

    do {
      session = try await authService.refreshSession(accessToken: session.accessToken, session: session)
    } catch {
      // Keep the current UI state if a background refresh fails.
    }
  }
}

#Preview {
  MainContainerView(session: .constant(AuthSession()))
}
