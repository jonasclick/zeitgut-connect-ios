//
//  MarketplaceView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import SwiftUI

struct MarketplaceView: View {
    var body: some View {
      VStack (alignment: .leading){
        Text("Marktplatz")
          .font(.system(size: 28))
          .bold()
          .padding(.bottom, 10)
        
        Text("Anfragen")
          .font(.system(size: 20))
          .bold()
        
        ScrollView (.vertical, showsIndicators: false) {
          VStack (spacing: 12) {
            ForEach(MarketplaceSampleData.requests, id: \.id) { requestOffer in
              RequestOfferView(requestOffer: requestOffer)
            }
          }
        }
        Text("Angebote")
          .font(.system(size: 20))
          .bold()
        ScrollView (.vertical, showsIndicators: false) {
          VStack (spacing: 12) {
            ForEach(MarketplaceSampleData.offers, id: \.id) { requestOffer in
              RequestOfferView(requestOffer: requestOffer)
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
    MarketplaceView()
}
