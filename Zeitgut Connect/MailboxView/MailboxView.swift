//
//  MailboxView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import SwiftUI

struct MailboxView: View {
    var body: some View {
      VStack (alignment: .leading){
        Text("Briefkasten")
          .font(.system(size: 28))
          .bold()
          .padding(.bottom, 10)

        Text("Bitte prüfe folgende Transaktionen")
            .font(.system(size: 20))
            .bold()
        
        ScrollView (.vertical, showsIndicators: false) {
          VStack (spacing: 12) {
            ActivityCardView(activity: Activity(
              isReceived: false,
              category: "Mit dem Hund spazieren",
              dateString: "18.02.26",
              personName: "Ruben Lüti",
              duration: 2.5
            ))
            AcceptDenyButtonsView()
              .padding(.bottom, 18)
            ActivityCardView(activity: Activity(
              isReceived: true,
              category: "Einkaufshilfe",
              dateString: "19.02.26",
              personName: "Marco Tanner",
              duration: 1
            ))
            AcceptDenyButtonsView()
              .padding(.bottom, 18)
          }
          
          
        }
        // Push Content to top of screen
        Spacer()
      }
      .padding()
    }
}

#Preview {
    MailboxView()
}
