//
//  AppBackgroundModifier.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//


import SwiftUI

struct AppBackgroundModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(
        Image("app-background")
          .resizable()
          .aspectRatio(contentMode: .fill)
      )
      .ignoresSafeArea()
  }
}

// Extension
extension View {
  func applyAppBackground() -> some View {
    self.modifier(AppBackgroundModifier())
  }
}
