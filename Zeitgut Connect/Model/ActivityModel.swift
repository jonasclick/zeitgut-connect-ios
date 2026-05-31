//
//  ActivityModel.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import Foundation

struct Activity {
  let isReceived: Bool      // true = "erhalten", false = "gegeben"
  let category: String      // z.B. "Einkaufshilfe"
  let dateString: String    // z.B. "14.02.26"
  let personName: String    // z.B. "Marco Tanner"
  let duration: Double      // in hours, z.B. 1.5
}
