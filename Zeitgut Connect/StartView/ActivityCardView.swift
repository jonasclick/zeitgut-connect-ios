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
        // Icon and given / taken info
        HStack {
          Image(systemName: activity.isReceived ? "gift" : "arrow.up.heart.fill")
            .foregroundStyle(Color.softShell)
            .frame(width: 36, height: 36)
            .background(
              Capsule()
                .fill(Color.delightfulOcean)
            )
          Text(activity.isReceived ? "Du hast erhalten" : "Du hast gegeben")
            .fontWeight(.light)
          Spacer()
        }
        .padding(.bottom, 4)
        
        // Activity Category and Date
        HStack {
          Text(activity.category)
            .font(.system(size: 20))
            .bold()
          Spacer()
          Text(activity.dateString)
            .fontWeight(.light)
        }
        .padding(.bottom, 4)
        
        // Person and Time Duration
        HStack (spacing: 5) {
          Text(activity.isReceived ? "von" : "für")
            .fontWeight(.light)
          Text(activity.personName)
            .bold()
          Spacer()
          Text(activity.duration.formatted(.number.precision(.fractionLength(1))))
            .bold()
          Text("Stunden")
            .fontWeight(.light)
        }
      }
      .padding(14)
      .background(Color.silentMint)
      .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

#Preview {
  ActivityCardView(activity: Activity(
    isReceived: false,
    category: "Einkaufshilfe",
    dateString: "14.02.26",
    personName: "Marco Tanner",
    duration: 1.5
  ))
  .padding()
}
