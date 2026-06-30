//
//  ActivityCardView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//

import SwiftUI

struct ActivityCardView: View {
  let activity: Activity
  
    var body: some View {
      VStack {
        
        // Activity Category and Date
        HStack {
          Image(systemName: activity.isReceived ? "gift" : "arrow.up.heart.fill")
            .foregroundStyle(Color.softShell)
            .frame(width: 36, height: 36)
            .background(
              Capsule()
                .fill(Color.delightfulOcean)
            )
          Text(activity.category)
            .font(.system(size: 20))
            .bold()
          Spacer()
          Text(activity.dateString)
            .fontWeight(.light)
        }
        
        // Person and Time Duration
        HStack (spacing: 0) {
          Text(activity.isReceived ? "von" : "für")
            .fontWeight(.light)
            .padding(.trailing, 5)
          Text(activity.personName)
            .bold()
          Spacer()
          Text(activity.duration.formatted(.number.precision(.fractionLength(1))))
            .bold()
          Text("h")
            .bold()
            .padding(.trailing, 5)
          // Icon and given / taken info
          Text(activity.isReceived ? "erhalten" : "gegeben")
            .fontWeight(.light)
        }
      }
      .padding(14)
      .background(Color.silentMint)
      .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

#Preview {
  VStack(spacing: 12) {
    ActivityCardView(
      activity: Activity(
        id: "preview-1",
        isReceived: true,
        category: "Einkaufshilfe",
        dateString: "14.02.26",
        personName: "Marco Tanner",
        duration: 1.5
      )
    )

    ActivityCardView(
      activity: Activity(
        id: "preview-2",
        isReceived: false,
        category: "Gartenarbeit",
        dateString: "18.02.26",
        personName: "Anna Meier",
        duration: 2.0
      )
    )
  }
  .padding()
  .background(Color.white)
}
