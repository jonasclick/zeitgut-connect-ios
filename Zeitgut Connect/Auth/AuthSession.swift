import Foundation

struct AuthSession: Equatable {
    var isLoggedIn = false
    var accessToken = ""
    var displayName = ""
    var email = ""
    var tenantId = ""
    var userId = ""
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
}

struct MeResponse: Decodable {
    let authenticated: Bool
    let isAssigned: Bool
    let userId: String?
    let email: String?
    let displayName: String?
    let tenantId: String?
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
