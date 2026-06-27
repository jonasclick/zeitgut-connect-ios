//
//  ActivityModel.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import Foundation

struct Activity: Identifiable {
  let id: String
  let isReceived: Bool      // true = "erhalten", false = "gegeben"
  let category: String      // z.B. "Einkaufshilfe"
  let dateString: String    // z.B. "14.02.26"
  let personName: String    // z.B. "Marco Tanner"
  let duration: Double      // in hours, z.B. 1.5
}

struct TransactionPayload: Decodable {
  let id: String
  let date: String
  let creatorId: String
  let creatorName: String
  let partnerId: String
  let partnerName: String
  let direction: String
  let category: String
  let durationMinutes: Double
  let status: String
  let createdAt: String

  func toActivity(for memberId: String) -> Activity {
    let isReceived = partnerId == memberId
    let personName = isReceived ? creatorName : partnerName

    return Activity(
      id: id,
      isReceived: isReceived,
      category: category,
      dateString: Self.displayDate(from: date),
      personName: personName,
      duration: durationMinutes / 60
    )
  }

  private static func displayDate(from value: String) -> String {
    let parser = DateFormatter()
    parser.calendar = Calendar(identifier: .gregorian)
    parser.locale = Locale(identifier: "en_US_POSIX")
    parser.dateFormat = "yyyy-MM-dd"

    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "de_CH")
    formatter.dateFormat = "dd.MM.yy"

    guard let date = parser.date(from: value) else {
      return value
    }

    return formatter.string(from: date)
  }
}

struct TransactionsResponse: Decodable {
  let authenticated: Bool
  let isAssigned: Bool
  let transactions: [TransactionPayload]
}
