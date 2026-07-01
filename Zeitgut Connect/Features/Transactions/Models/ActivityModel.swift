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
    let isCurrentMemberCreator = creatorId == memberId
    let isReceived = isCurrentMemberCreator ? direction == "received" : direction == "given"
    let personName = isCurrentMemberCreator ? partnerName : creatorName

    return Activity(
      id: id,
      isReceived: isReceived,
      category: category,
      dateString: AppDateFormatter.displayDate(fromBackendDate: date),
      personName: personName,
      duration: durationMinutes / 60
    )
  }

}

struct TransactionsResponse: Decodable {
  let authenticated: Bool
  let isAssigned: Bool
  let transactions: [TransactionPayload]
}

struct MailboxResponse: Decodable {
  let authenticated: Bool
  let isAssigned: Bool
  let currentMemberId: String?
  let transactions: [TransactionPayload]
}

struct MailboxActionResponse: Decodable {
  let authenticated: Bool
  let isAssigned: Bool
  let transaction: TransactionPayload?
  let member: MemberPayload?
}

struct MemberOption: Decodable, Identifiable, Hashable {
  let id: String
  let name: String?
  let timeBalanceMinutes: Int?

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case timeBalanceMinutes
    case timeBalance
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decodeIfPresent(String.self, forKey: .name)

    if let minutes = try container.decodeIfPresent(Int.self, forKey: .timeBalanceMinutes) {
      timeBalanceMinutes = minutes
    } else if let hours = try container.decodeIfPresent(Double.self, forKey: .timeBalance) {
      timeBalanceMinutes = Int((hours * 60).rounded())
    } else {
      timeBalanceMinutes = nil
    }
  }

  var displayName: String {
    name?.isEmpty == false ? name! : "Unbekannte Person"
  }
}

struct MembersResponse: Decodable {
  let authenticated: Bool
  let isAssigned: Bool
  let currentMemberId: String?
  let members: [MemberOption]
}

struct TimeCategoryOption: Decodable, Identifiable, Hashable {
  let id: String
  let label: String
}

struct TimeCategoriesResponse: Decodable {
  let authenticated: Bool
  let isAssigned: Bool
  let categories: [TimeCategoryOption]
}

struct CreateTransactionRequest: Encodable {
  let date: String
  let direction: String
  let partnerId: String
  let categoryId: String
  let durationMinutes: Int
}

struct CreateTransactionResponse: Decodable {
  let authenticated: Bool
  let isAssigned: Bool
  let transaction: TransactionPayload?
}
