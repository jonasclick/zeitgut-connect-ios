//
//  StartView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//

import SwiftUI

struct StartView: View {
    var body: some View {
      VStack (alignment: .leading){
        
        Text("Zeitgut Connect")
          .font(.largeTitle)
          .padding(.top, 20)
          .padding(.bottom, 25)
        
        HStack {
          Text("Dein Stundensaldo")
            .font(.system(size: 20))
            .bold()
          Spacer()
          Text("5.4h")
            .font(.system(size: 20))
            .bold()
            .frame(width: 80, height: 80)
            .background(
              Capsule()
                .fill(Color.silentMint)
              )
        }
        .padding(.bottom, 40)
        Text("Letzte Aktivitäten")
          .font(.system(size: 20))
          .bold()
        
        ScrollView (.vertical, showsIndicators: false) {
          VStack (spacing: 12) {
            ActivityCardView(activity: Activity(
              isReceived: true,
              category: "Einkaufshilfe",
              dateString: "14.02.26",
              personName: "Marco Tanner",
              duration: 1.5
            ))
            ActivityCardView(activity: Activity(
              isReceived: false,
              category: "Klavierunterricht",
              dateString: "11.02.26",
              personName: "Lina Pfister",
              duration: 1
            ))
            ActivityCardView(activity: Activity(
              isReceived: true,
              category: "Gartenarbeit",
              dateString: "09.02.26",
              personName: "Lydia Berberat",
              duration: 2.3
            ))
            ActivityCardView(activity: Activity(
              isReceived: false,
              category: "Klavierunterricht",
              dateString: "01.02.26",
              personName: "Lina Pfister",
              duration: 1
            ))
            ActivityCardView(activity: Activity(
              isReceived: true,
              category: "Computerhilfe",
              dateString: "12.01.26",
              personName: "Marco Tanner",
              duration: 1.2
            ))
          }
          
         
        }
        // Push Content to top of screen
        Spacer()
      }
      .padding()
    }
}

#Preview {
    StartView()
}
