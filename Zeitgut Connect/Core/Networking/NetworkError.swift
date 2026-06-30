import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case server(statusCode: Int, body: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The backend response was invalid."
        case let .server(statusCode, body):
            return "Backend returned HTTP \(statusCode): \(body)"
        }
    }
}
