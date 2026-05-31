//
//  RequestOfferView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import SwiftUI

struct RequestOfferView: View {
  let requestOffer: RequestOffer
  
    var body: some View {
      VStack (alignment: .leading, spacing: 2) {
        // Activity Category
          Text(requestOffer.category)
            .font(.system(size: 20))
            .bold()
        
        // Person and Time Duration
        HStack (spacing: 5) {
          Text(requestOffer.isRequest ? "von" : "für")
            .fontWeight(.light)
          Text(requestOffer.personName)
            .bold()
          Spacer()
        }
        
      }
      .padding(14)
      .background(Color.silentMint)
      .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

#Preview {
    RequestOfferView(requestOffer: RequestOffer(
      isRequest: true, category: "Gartenarbeit", personName: "Margrit Buri"
    ))
    .padding()
}
