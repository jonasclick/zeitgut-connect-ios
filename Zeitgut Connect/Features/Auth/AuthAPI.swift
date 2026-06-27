import Foundation
import OSLog

enum AuthAPIError: LocalizedError {
    case invalidResponse
    case missingApplicationContext
    case missingPresentationContext
    case missingMSALResult
    case server(statusCode: Int, body: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The backend response was invalid."
        case .missingApplicationContext:
            return "MSAL application context was not initialized."
        case .missingPresentationContext:
            return "No active iOS view controller was available to present Microsoft sign-in."
        case .missingMSALResult:
            return "Microsoft sign-in completed without a result or error."
        case let .server(statusCode, body):
            return "Backend returned HTTP \(statusCode): \(body)"
        }
    }
}

struct AuthAPI {
    private static let baseURL = URL(string: "https://dev-chn-zgcn-fapp-02.azurewebsites.net/api")!
    private static let logger = Logger(subsystem: "com.github.jonasclick.zeitgutconnect", category: "ZeitgutAuth")
    private let decoder = JSONDecoder()

    func fetchMe(accessToken: String) async throws -> (MeResponse, String) {
        let request = authorizedRequest(path: "me", method: "GET", accessToken: accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        return try decodeResponse(MeResponse.self, data: data, response: response)
    }

    func fetchMyTransactions(accessToken: String) async throws -> (TransactionsResponse, String) {
        let request = authorizedRequest(path: "me/transactions", method: "GET", accessToken: accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        return try decodeResponse(TransactionsResponse.self, data: data, response: response)
    }

    func joinAssociation(accessToken: String, inviteCode: String) async throws -> (JoinResponse, String) {
        var request = authorizedRequest(path: "me/join", method: "POST", accessToken: accessToken)
        request.httpBody = try JSONSerialization.data(withJSONObject: ["inviteCode": inviteCode])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        return try decodeResponse(JoinResponse.self, data: data, response: response)
    }

    private func authorizedRequest(path: String, method: String, accessToken: String) -> URLRequest {
        var request = URLRequest(url: Self.baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15
        return request
    }

    private func decodeResponse<T: Decodable>(_ type: T.Type, data: Data, response: URLResponse) throws -> (T, String) {
        guard let httpResponse = response as? HTTPURLResponse else {
            Self.logger.error("AUTH_API invalid non-HTTP response for \(String(describing: type))")
            throw AuthAPIError.invalidResponse
        }

        let body = String(decoding: data, as: UTF8.self)
        Self.logger.debug("AUTH_API status=\(httpResponse.statusCode) body=\(body, privacy: .public)")
        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw AuthAPIError.server(statusCode: httpResponse.statusCode, body: body)
        }

        return (try decoder.decode(type, from: data), body)
    }
}
