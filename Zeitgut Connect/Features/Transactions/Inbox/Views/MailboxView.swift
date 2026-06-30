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
            ForEach(TransactionSampleData.inboxActivities) { activity in
              ActivityCardView(activity: activity)
              AcceptDenyButtonsView()
                .padding(.bottom, 18)
            }
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
