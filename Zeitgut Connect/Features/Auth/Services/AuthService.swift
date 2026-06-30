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
