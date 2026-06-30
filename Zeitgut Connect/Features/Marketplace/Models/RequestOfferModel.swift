//
//  RequestOfferModel.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import Foundation

struct RequestOffer: Identifiable {
  var id: String { "\(isRequest)-\(category)-\(personName)" }
  let isRequest: Bool      // true = "Anfrage für Hilfe", false = "Angebot für Hilfe"
  let category: String      // z.B. "Einkaufshilfe"
  let personName: String    // z.B. "Marco Tanner"
}
