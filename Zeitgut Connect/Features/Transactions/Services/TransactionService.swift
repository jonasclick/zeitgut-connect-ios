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

    func fetchMailbox(accessToken: String) async throws -> APIResponse<MailboxResponse> {
        try await apiClient.send(APIEndpoint(
            path: "me/mailbox",
            accessToken: accessToken
        ))
    }

    func acceptMailboxTransaction(
        accessToken: String,
        transactionId: String
    ) async throws -> APIResponse<MailboxActionResponse> {
        try await apiClient.send(APIEndpoint(
            path: "me/mailbox/\(transactionId)/accept",
            method: .post,
            accessToken: accessToken
        ))
    }

    func denyMailboxTransaction(
        accessToken: String,
        transactionId: String
    ) async throws -> APIResponse<MailboxActionResponse> {
        try await apiClient.send(APIEndpoint(
            path: "me/mailbox/\(transactionId)/deny",
            method: .post,
            accessToken: accessToken
        ))
    }

    func fetchMembers(accessToken: String) async throws -> APIResponse<MembersResponse> {
        try await apiClient.send(APIEndpoint(
            path: "members",
            accessToken: accessToken
        ))
    }

    func fetchTimeCategories(accessToken: String) async throws -> APIResponse<TimeCategoriesResponse> {
        try await apiClient.send(APIEndpoint(
            path: "time-categories",
            accessToken: accessToken
        ))
    }

    func createTransaction(
        accessToken: String,
        request: CreateTransactionRequest
    ) async throws -> APIResponse<CreateTransactionResponse> {
        try await apiClient.send(APIEndpoint(
            path: "transactions",
            method: .post,
            body: request,
            accessToken: accessToken
        ))
    }
}
