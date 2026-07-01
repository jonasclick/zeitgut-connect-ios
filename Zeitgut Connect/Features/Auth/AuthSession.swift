import Foundation

struct AuthSession: Equatable {
    var isLoggedIn = false
    var accessToken = ""
    var displayName = ""
    var email = ""
    var tenantId = ""
    var userId = ""
    var timeBalanceMinutes: Int?
    var principalJson = ""
}

struct PrincipalClaim: Decodable {
    let typ: String?
    let val: String?
}

struct PrincipalPayload: Decodable {
    let auth_typ: String?
    let claims: [PrincipalClaim]?
}

struct MemberPayload: Decodable {
    let id: String?
    let tenantId: String?
    let name: String?
    let email: String?
    let timeBalanceMinutes: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case tenantId
        case name
        case email
        case timeBalanceMinutes
        case timeBalance
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        tenantId = try container.decodeIfPresent(String.self, forKey: .tenantId)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)

        if let minutes = try container.decodeIfPresent(Int.self, forKey: .timeBalanceMinutes) {
            timeBalanceMinutes = minutes
        } else if let hours = try container.decodeIfPresent(Double.self, forKey: .timeBalance) {
            timeBalanceMinutes = Int((hours * 60).rounded())
        } else {
            timeBalanceMinutes = nil
        }
    }
}

struct MeResponse: Decodable {
    let authenticated: Bool
    let isAssigned: Bool
    let userId: String?
    let email: String?
    let displayName: String?
    let tenantId: String?
    let member: MemberPayload?
    let principal: PrincipalPayload?
}

struct JoinResponse: Decodable {
    let authenticated: Bool
    let isAssigned: Bool
    let tenantId: String?
    let member: MemberPayload?
}

extension PrincipalPayload {
    func claimValue(_ claimTypes: String...) -> String? {
        for claimType in claimTypes {
            if let value = claims?.first(where: { $0.typ == claimType })?.val, value.isEmpty == false {
                return value
            }
        }

        return nil
    }
}
