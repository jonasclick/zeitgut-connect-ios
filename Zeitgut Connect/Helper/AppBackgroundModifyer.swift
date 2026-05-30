//
//  AppBackgroundModifyer.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//


import SwiftUI

// Modifier definieren
struct AppBackgroundModifyer: ViewModifier {
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
    self.modifier(AppBackgroundModifyer())
  }
}
