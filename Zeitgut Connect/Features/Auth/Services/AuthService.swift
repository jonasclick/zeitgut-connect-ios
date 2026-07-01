import Foundation

struct AuthService {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchMe(accessToken: String) async throws -> APIResponse<MeResponse> {
        try await apiClient.send(APIEndpoint(
            path: "me",
            accessToken: accessToken
        ))
    }

    func refreshSession(accessToken: String, session: AuthSession) async throws -> AuthSession {
        let meResult = try await fetchMe(accessToken: accessToken)
        let meResponse = meResult.value

        var refreshedSession = session
        refreshedSession.displayName = meResponse.member?.name ?? meResponse.displayName ?? session.displayName
        refreshedSession.email = meResponse.member?.email ?? meResponse.email ?? session.email
        refreshedSession.tenantId = meResponse.member?.tenantId ?? meResponse.tenantId ?? session.tenantId
        refreshedSession.userId = meResponse.member?.id ?? meResponse.userId ?? session.userId
        refreshedSession.timeBalanceMinutes = meResponse.member?.timeBalanceMinutes ?? session.timeBalanceMinutes
        refreshedSession.isLoggedIn = meResponse.isAssigned
        return refreshedSession
    }

    func joinAssociation(accessToken: String, inviteCode: String) async throws -> APIResponse<JoinResponse> {
        try await apiClient.send(APIEndpoint(
            path: "me/join",
            method: .post,
            body: JoinAssociationRequest(inviteCode: inviteCode),
            accessToken: accessToken
        ))
    }
}

private struct JoinAssociationRequest: Encodable {
    let inviteCode: String
}
