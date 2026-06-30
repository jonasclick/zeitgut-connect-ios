import Foundation
import OSLog

struct APIClient {
    private static let logger = Logger(subsystem: "com.github.jonasclick.zeitgutconnect", category: "Networking")

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL = AppEnvironment.backendBaseURL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func send<Response: Decodable>(_ endpoint: APIEndpoint<Response>) async throws -> APIResponse<Response> {
        let request = try makeRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)
        return try decode(Response.self, data: data, response: response)
    }

    private func makeRequest<Response>(for endpoint: APIEndpoint<Response>) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if let accessToken = endpoint.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func decode<Response: Decodable>(
        _ type: Response.Type,
        data: Data,
        response: URLResponse
    ) throws -> APIResponse<Response> {
        guard let httpResponse = response as? HTTPURLResponse else {
            Self.logger.error("API_CLIENT invalid non-HTTP response for \(String(describing: type))")
            throw NetworkError.invalidResponse
        }

        let body = String(decoding: data, as: UTF8.self)
        Self.logger.debug("API_CLIENT status=\(httpResponse.statusCode) body=\(body, privacy: .public)")

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                Self.logger.notice("API_CLIENT authentication required for \(String(describing: type))")
                NotificationCenter.default.post(name: .authenticationRequired, object: nil)
                throw NetworkError.authenticationRequired
            }

            throw NetworkError.server(statusCode: httpResponse.statusCode, body: body)
        }

        return APIResponse(value: try decoder.decode(type, from: data), rawBody: body)
    }
}
