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
            RequestOfferView(requestOffer: RequestOffer(
              isRequest: true, category: "Gartenarbeit", personName: "Margrit Buri"
            ))
            RequestOfferView(requestOffer: RequestOffer(
              isRequest: true, category: "Briefversand abpacken", personName: "Regula Peters"
            ))
            RequestOfferView(requestOffer: RequestOffer(
              isRequest: true, category: "Einkaufshilfe", personName: "Margrit Buri"
            ))
          }
        }
        Text("Angebote")
          .font(.system(size: 20))
          .bold()
        ScrollView (.vertical, showsIndicators: false) {
          VStack (spacing: 12) {
            RequestOfferView(requestOffer: RequestOffer(
              isRequest: false, category: "Handwerkliche Arbeiten", personName: "Marco Tanner"
            ))
            RequestOfferView(requestOffer: RequestOffer(
              isRequest: false, category: "Klavierunterricht", personName: "Margrit Burgi"
            ))
            RequestOfferView(requestOffer: RequestOffer(
              isRequest: false, category: "Deutsch lernen (Sprachtandem)", personName: "Jakob Rieder"
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
    MarketplaceView()
}
