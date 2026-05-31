//
//  AcceptDenyButtonsView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import SwiftUI

struct AcceptDenyButtonsView: View {
  @State private var isShowingConfirmation = false
  
    var body: some View {
      HStack (spacing: 12) {
        
        // DENY (with confirmation dialog)
        Button(action: {
          isShowingConfirmation = true
        }) {
            Text("Ablehnen")
            .foregroundStyle(Color.delightfulOcean)
            .bold()
            .padding(.vertical, 12)
            .padding(.horizontal, 35)
            .foregroundColor(.white)
            .background(Color.softError)
            .cornerRadius(15)
        }
        .confirmationDialog(
          "Bist du sicher?",
          isPresented: $isShowingConfirmation,
          titleVisibility: .visible
        ) {
          // Action Buttons inside
          Button("Ja, Zeiterfassung ablehnen", role: .destructive) {
            // ACTION
            print("Transaction denied.")
          }
          Button("Nein, zurück") {
            print("Stopped.")
          }
        } message: {
          Text("Willst du diese Zeiterfassung wirklich ablehnen? Dies kann nicht rückgängig gemacht werden.")
        }
        
        // ACCEPT (without confirmation dialog)
        Button(action: {
          print("Transaction accepted.")
        }) {
          Text("Annehmen")
            .foregroundStyle(Color.delightfulOcean)
            .bold()
            .padding(.vertical, 12)
            .padding(.horizontal, 35)
            .foregroundColor(.white)
            .background(Color.mutedSuccess)
            .cornerRadius(15)
        }
      }
    }
}

#Preview {
    AcceptDenyButtonsView()
}
