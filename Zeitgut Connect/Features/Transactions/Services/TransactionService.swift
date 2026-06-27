import Foundation

struct TransactionService {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchMyTransactions(accessToken: String) async throws -> APIResponse<TransactionsResponse> {
        try await apiClient.send(APIEndpoint(
            path: "me/transactions",
            accessToken: accessToken
        ))
    }
}
